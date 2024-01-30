#include <flexpret.h>

/* Linker */
extern uint32_t __etext;
extern uint32_t __sdata;
extern uint32_t __edata;
extern uint32_t __sbss;
extern uint32_t __ebss;
extern uint32_t end;

//prototype of main
int main(void);

void Reset_Handler() {
    // Get hartid
    uint32_t hartid = read_hartid();
    // Only thread 0 performs the setup,
    // the other threads busy wait until ready.
    if (hartid == 0) {
        // Copy .data section into the RAM
        uint32_t size   = &__edata - &__sdata;
        uint32_t *pDst  = (uint32_t*)&__sdata; // RAM
        uint32_t *pSrc  = (uint32_t*)&__etext; // ROM

        for (uint32_t i = 0; i < size; i++) {
            *pDst++ = *pSrc++;
        }

        // Init. the .bss section to zero in RAM
        size = (uint32_t)&__ebss - (uint32_t)&__sbss;
        pDst = (uint32_t*)&__sbss;
        for(uint32_t i = 0; i < size; i++) {
            *pDst++ = 0;
        }
        
    }
    // Jump to main (which should be the bootloader)
    main();

    // Exit the program.
    write_tohost(CSR_TOHOST_FINISH);
    //_fp_finish();
    
    // Infinite loop
    while (1);
}