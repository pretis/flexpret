/**
 * FlexPRET's startup code in C
 * 
 * Authors:
 * - Shaokai Lin
 * - Samuel Berkun
 */

#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include "tinyalloc/tinyalloc.h"

#define DSPM_LIMIT          ((void*)0x20040000) // 0x40000 = 256K
#define TA_MAX_HEAP_BLOCK   1000
#define TA_ALIGNMENT        4

#ifndef NUM_THREADS
#define NUM_THREADS 1
#endif

extern uint32_t __etext;
extern uint32_t __data_start__;
extern uint32_t __data_end__;
extern uint32_t __bss_start__;
extern uint32_t __bss_end__;
extern uint32_t end;

static uint32_t __ready__    = 0; // FIXME: Replace by a condition variable.
static uint32_t __num_done__ = 0; // FIXME: Replace by a condition variable.

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
void Reset_Handler(uint32_t hartid) {
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
        lock_acquire();
        __ready__ = 1;
        lock_release();
    } else {
        // Wait for thread 0 to finish setup.
        // FIXME: Use delay until (DU)
        // for precise synchronization.
        while (__ready__ != 1);
    }

    // Call main().
    main();

    // Exit by calling the _exit() syscall.
    if (hartid == 0) {
        lock_acquire();
        __num_done__ += 1;
        lock_release();

        // Wait for all the threads to finish.
        while (__num_done__ < NUM_THREADS);

        // Exit the program.
        _exit(0);
    } else {
        lock_acquire();
        __num_done__ += 1;
        lock_release();
        while (1);
    }
}
