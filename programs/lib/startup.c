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
#include <flexpret_exceptions.h>
#ifndef BOOTLOADER 
#include <flexpret_lock.h>
#include <flexpret_thread.h>
#include "tinyalloc/tinyalloc.h" // Only include tinyalloc in applications, not bootloader
#endif

// Memory map
// 0x20000000 -> 0x20001000 (4KB) Bootloader DMEM
// 0x20001000 -> 0x20005000 (16KB) App DMEM
// 0x20005000 -> 0x20006000 (4KB) Thread stacks (1KB each)
#define DSPM_LIMIT          ((void*)0x20005000) // 0x20005000 is where the stacks start
#define TA_MAX_HEAP_BLOCK   256
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
#ifndef BOOTLOADER
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
#endif // BOOTLOADER

/**
 * Initialize initialized global variables, set uninitialized global variables
 * to zero, configure tinyalloc, and jump to main.
 */
#ifdef BOOTLOADER
void Reset_Handler() {
    // Get hartid
    uint32_t hartid = read_hartid();
    _fp_print(hartid);
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
        
    }
    // Jump to main (which should be the bootloader)
    main();

    // Exit the program.
    _exit(0);
    
    // Infinite loop
    while (1);
}
#else
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
        for (int i = 0; i < NUM_THREADS; i++)
            slots[i] = i;
        // Disable slots with ID >= NUM_THREADS,
        for (int j = NUM_THREADS; j < SLOTS_SIZE; j++)
            slots[j] = SLOT_D;
        hwlock_acquire();
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
#endif
