OUTPUT_ARCH("riscv")

/*INCLUDE flexpret_config.ld*/
INCLUDE flexpret_hwconfig.ld
INCLUDE flexpret_swconfig.ld
INCLUDE flexpret_bootloader_config.ld

ISPM_BOOTLOADER_END = BOOTLOADER_APP_START_ADDR;

/* TODO: Fix hardcoded 0x1000, potentially with some nm of the bootloader */
DSPM_BOOTLOADER_END = DSPM_START + 0x1000;
TOTAL_STACKSIZES = STACKSIZE * NUM_THREADS;

MEMORY
{
    ROM (rx)  : ORIGIN = ISPM_BOOTLOADER_END, LENGTH = ISPM_END - ISPM_BOOTLOADER_END
    RAM (rwx) : ORIGIN = DSPM_BOOTLOADER_END, LENGTH = DSPM_END - DSPM_BOOTLOADER_END
    STACK (rw) : ORIGIN = DSPM_END - TOTAL_STACKSIZES, LENGTH = TOTAL_STACKSIZES
}

OUTPUT_ARCH("riscv")

ENTRY(_start)
EXTERN(_vectors)
SECTIONS
{
    .text : {
        __stext = ABSOLUTE(.);
        *(.vectors)
        *(.isr_vector)
        *(.text .text.*)
        *(.eh_frame)
        . = ALIGN(4);
        __etext = ABSOLUTE(.);
    } > ROM

    .data : ALIGN(4) {
        __sdata = ABSOLUTE(.);
        *(.data .data.*)
        *(.sdata .sdata.* .sdata2.*)
        *(.rodata .rodata.* .srodata .srodata.*)
        *(.gnu.linkonce.d.*)
        *(.gnu.linkonce.s.*)
        CONSTRUCTORS
        . = ALIGN(4);
        __edata = ABSOLUTE(.);
    } > RAM AT > ROM

    PROVIDE(__global_pointer$ = __sdata + ((__edata - __sdata) / 2));

    .bss : ALIGN(4) {
        __sbss = ABSOLUTE(.);
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(.gnu.linkonce.b.*)
        *(.gnu.linkonce.sb.*)
        *(COMMON)
        . = ALIGN(32);
        __ebss = ABSOLUTE(.);
    } > RAM

    __end = ABSOLUTE(.);

    .heap : ALIGN(4) {
        __sheap = ABSOLUTE(.);
        __eheap = ABSOLUTE(DSPM_END - TOTAL_STACKSIZES);
    } > RAM

    .stack : ALIGN(4) {
        __estack = ABSOLUTE(.);
        __sstack =  ABSOLUTE(. + TOTAL_STACKSIZES);
    } > STACK

    PROVIDE(__stack_start$ = __sstack);
}