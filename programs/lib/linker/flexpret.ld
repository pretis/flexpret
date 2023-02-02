OUTPUT_ARCH("riscv")

MEMORY
{
    ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 20K
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 20K
}

SECTIONS
{
    .text :
    {
        *(.isr_vector)
        *(.text*)
        *(.eh_frame*)

        /* All text end */
        . = ALIGN(4);
        __etext = .;
    } > ROM

    .data :
    {
        __data_start__ = .;
        *(.data .data.*)
        *(.rodata*)
        *(.gnu.linkonce.d.*)
    } > RAM AT> ROM

    .sdata :
    {
        /* Configure global pointer: https://www.sifive.com/blog/all-aboard-part-3-linker-relaxation-in-riscv-toolchain */
        . = ALIGN(4);
        PROVIDE( __global_pointer$ = . + 0x800 );

        *(.sdata .sdata.* .sdata2.*)
        *(.srodata.*)
        *(.gnu.linkonce.s.*)

        /* All data end */
        . = ALIGN(4);
        __data_end__ = .;
        
    } > RAM AT> ROM

    .bss :
    {
        __bss_start__ = .;
        *(.bss)
        *(.bss.*)
        *(.gnu.linkonce.b.*)
    } > RAM

    .sbss :
    {
        *(.sbss)
        *(.sbss.*)

        /* All bss end */
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    end = .;
}

