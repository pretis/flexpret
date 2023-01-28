/**
 * FlexPRET's startup code in C
 * 
 * Authors:
 * - Shaokai Lin
 * - Samuel Berkun
 */

#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <stdint.h>
#include <stdbool.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>
#include "tinyalloc/tinyalloc.h"

#define DSPM_LIMIT          ((void*)0x20040000) // 0x40000 = 256K
#define TA_MAX_HEAP_BLOCK   1000
#define TA_ALIGNMENT        4

/* Linker */
extern uint32_t __etext;
extern uint32_t __data_start__;
extern uint32_t __data_end__;
extern uint32_t __bss_start__;
extern uint32_t __bss_end__;
extern uint32_t end;

/* Threading */
static bool     __ready__;
extern bool     exit_requested[NUM_THREADS];
extern uint32_t num_threads_busy;
extern uint32_t num_threads_exited;

//prototype of main
int main(void);

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
void Reset_Handler() {
    // Get hartid
    uint32_t hartid = read_hartid();

    // Only thread 0 performs the setup,
    // the other threads busy wait until ready.
    if (hartid == 0) {
        // Copy .data section into the RAM
        uint32_t size   = &__data_end__ - &__data_start__;
        uint32_t *pDst  = (uint32_t*)&__data_start__;       // RAM
        uint32_t *pSrc  = (uint32_t*)&__etext;              // ROM

        for (uint32_t i = 0; i < size; i++) {
            *pDst++ = *pSrc++;
        }

        // Init. the .bss section to zero in RAM
        size = (uint32_t)&__bss_end__ - (uint32_t)&__bss_start__;
        pDst = (uint32_t*)&__bss_start__;
        for(uint32_t i = 0; i < size; i++) {
            *pDst++ = 0;
        }

        // Initialize tinyalloc.
        ta_init( 
            &end, // start of the heap space
            DSPM_LIMIT,
            TA_MAX_HEAP_BLOCK, 
            16, // split_thresh: 16 bytes (Only used when reusing blocks.)
            TA_ALIGNMENT
        );

        // Signal ready.
        hwlock_acquire();
        __ready__ = true;
        hwlock_release();

        /**
         * Configure flexible scheduling
         * 
         * The default schedule (i.e. slots) has
         * one slot per hardware thread. For example,
         * if FlexPRET has four threads, then the slots
         * are [T0 T1 T2 T3 D D D D]. The thread modes
         * (i.e. whether a thread is an HRTT or an SRTT)
         * are set by the user via thread_create() or
         * thread_map(). Here, during startup, they are
         * configured as HRTTs.
         * 
         * More fine-grained control of the schedule
         * can be done by the user via slot_set_hrtt(),
         * slot_set_srtt(), slot_disable(), and tmode_set().
         * But normally, the user does not need to
         * worry about them.
         */
        // Disable slots with ID >= NUM_THREADS,
        for (int j = NUM_THREADS; j < SLOTS_SIZE; j++) {
            slot_disable(j);
        }
        // and signal all the other threads to warm up,
        // i.e. begin from start.S and execute up to here.
        for (int i = 0; i < NUM_THREADS; i++) {
            slot_set_hrtt(i, i);
            tmode_set(i, TMODE_HA);
        }
    } else {
        // Wait for thread 0 to finish setup.
        // FIXME: Use delay until (DU)
        // for precise synchronization.
        while (!__ready__);
    }

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
            // Wake up the thread.
            tmode_active(i);
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
