#include <unistd.h>      // Declares _exit() with definition in syscalls.c.
#include <stdint.h>
#include <flexpret_io.h>

extern uint8_t _start;
extern uint32_t __etext;
extern uint32_t __data_start__;
extern uint32_t __data_end__;
extern uint32_t __bss_start__;
extern uint32_t __bss_end__;

//prototype of main
int main(void);

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

    // Call main().
    main();

    // Exit by calling the _exit() syscall.
    _exit(0);
}
