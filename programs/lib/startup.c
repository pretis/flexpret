/**
 * FlexPRET's startup code in C
 * 
 * Authors:
 * - Shaokai Lin
 * - Samuel Berkun
 */

#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <flexpret.h>

#include "tinyalloc/tinyalloc.h"

#define TA_MAX_HEAP_BLOCK   1000
#define TA_ALIGNMENT        4

/* Linker */
extern uint32_t __stext;
extern uint32_t __etext;
extern uint32_t __sdata;
extern uint32_t __edata;
extern uint32_t __sbss;
extern uint32_t __ebss;
extern uint32_t __end;

/* Threading */
static bool     __ready__;
extern bool     exit_requested[NUM_THREADS];
extern uint32_t num_threads_busy;
extern uint32_t num_threads_exited;

//prototype of main
int main(void);

void syscalls_init(void);

/**
 * Allocate a requested memory and return a pointer to it.
 */
void *malloc(size_t size) {
    return ta_alloc(size);
}

/**
 * Allocate a requested memory, initial the memory to 0,
 * and return a pointer to it.
 */
void *calloc(size_t nitems, size_t size) {
    return ta_calloc(nitems, size);
}

/**
 * resize the memory block pointed to by ptr
 * that was previously allocated with a call
 * to malloc or calloc.
 */
void *realloc(void *ptr, size_t size) {
    return ta_realloc(ptr, size);
}

/**
 * Deallocate the memory previously allocated by a call to calloc, malloc, or realloc.
 */
void free(void *ptr) {
    ta_free(ptr);
}

/**
 * Initialize initialized global variables, set uninitialized global variables
 * to zero, configure tinyalloc, and jump to main.
 */
fp_lock_t _lock = LOCK_INITIALIZER;
void Reset_Handler() {
    // Get hartid
    uint32_t hartid = read_hartid();

    // Only thread 0 performs the setup,
    // the other threads busy wait until ready.
    if (hartid == 0) {
        // Copy .data section into the RAM
        uint32_t size   = &__edata - &__sdata;
        uint32_t *pDst  = (uint32_t*)&__sdata;              // RAM
        uint32_t *pSrc  = (uint32_t*)&__etext;              // ROM

        for (uint32_t i = 0; i < size; i++) {
            *pDst++ = *pSrc++;
        }

        // Init. the .bss section to zero in RAM
        size = (uint32_t)&__ebss - (uint32_t)&__sbss;
        pDst = (uint32_t*)&__sbss;
        for(uint32_t i = 0; i < size; i++) {
            *pDst++ = 0;
        }
        
        syscalls_init();

        // Initialize tinyalloc.
        ta_init( 
            &__end, // start of the heap space
            (void *) DSPM_END,
            TA_MAX_HEAP_BLOCK, 
            16, // split_thresh: 16 bytes (Only used when reusing blocks.)
            TA_ALIGNMENT
        );

        /**
         * Configure flexible scheduling
         * 
         * The default schedule (i.e. encoded in slots)
         * being set here allocates each hardware thread
         * a slot. For example,
         * if FlexPRET has four threads, then the slots
         * are [T0 T1 T2 T3 D D D D].
         * Here, during startup, they are
         * configured as HRTTs. After startup,
         * T1, T2, and T3 are put to sleep, and T1, T2,
         * and T3 are then used for SRTTs.
         * 
         * The user can set the thread modes when
         * thread_create() or thread_map() is called. 
         * 
         * If the user wants to change the schedule,
         * the user can call slot_set(), slot_set_hrtt(),
         * slot_set_srtt(), slot_disable(), and tmode_set().
         * But normally, the user does not need to
         * worry about them since a "one-slot-per-thread"
         * schedule seems sufficient for most applications.
         */
        // Signal all the other (currently HRTT) threads
        // to wake up and execute up to here,
        // by allocating the slots to them.
        slot_t slots[8];
        for (int i = 0; i < NUM_THREADS; i++) {
            slots[i] = i;
        }
        // Disable slots with ID >= NUM_THREADS,
        for (int j = NUM_THREADS; j < SLOTS_SIZE; j++)
            slots[j] = SLOT_D;
        
        // Acquire lock and allow all threads to start execute as HRTTs
        hwlock_acquire();
        for (int i = 0; i < NUM_THREADS; i++) {
            tmode_set(i, TMODE_HA);
        }
        slot_set(slots, 8);
        hwlock_release();

        // FIXME: Wait for a worker thread to signal
        // ready-to-sleep and put it to sleep.

        // Signal everything is ready.
        hwlock_acquire();
        __ready__ = true;
        hwlock_release();
    } else {
        // FIXME: Signal thread 0 to put
        // the worker thread to sleep.

        // Wait for thread 0 to finish setup.
        while (!__ready__);
    }

    // Setup exception handling
    setup_exceptions();

    // Call main().
    if (hartid == 0) {
        main();
    } else {
        worker_main();
    }

    // Shutdown the program.
    if (hartid == 0) {
        /* Make sure all worker threads properly shutdown. */

        // Wait for all hardware worker threads
        // to finish their ongoing routines.
        while (num_threads_busy > 0);

        // Signal all threads besides T0 to exit.
        hwlock_acquire();
        for (int i = 1; i < NUM_THREADS; i++) {
            exit_requested[i] = true;
            // FIXME: If the thread is sleeping,
            // wake up the thread.
        }
        hwlock_release();

        // Wait for all hardware worker threads to exit.
        while (num_threads_exited < NUM_THREADS-1);

        // FIXME: Execute the main thread
        // clean up handlers here.

        // Exit the program.
        _exit(0);
    } else {
        while (1);
    }
}
