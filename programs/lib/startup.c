#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <stdint.h>
#include <flexpret_io.h>
#ifndef BOOTLOADER
#include "tinyalloc/tinyalloc.h"
#endif

#define DSPM_LIMIT          ((void*)0x2003E800) // 0x3E800 = 256K
#define TA_MAX_HEAP_BLOCK   1000
#define TA_ALIGNMENT        4

extern uint32_t __etext;
extern uint32_t __data_start__;
extern uint32_t __data_end__;
extern uint32_t __bss_start__;
extern uint32_t __bss_end__;
extern uint32_t end;

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
void Reset_Handler(void) {
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

    #ifndef BOOTLOADER
    // Initialize tinyalloc.
    ta_init( 
        &end, // start of the heap space
        DSPM_LIMIT,
        TA_MAX_HEAP_BLOCK, 
        16, // split_thresh: 16 bytes (Only used when reusing blocks.)
        TA_ALIGNMENT
    );
    #endif


    main();


    // Exit by calling the _exit() syscall.
    _exit(0);
}
