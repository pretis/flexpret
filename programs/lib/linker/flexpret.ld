OUTPUT_ARCH("riscv")

MEMORY
{
  ROM (rx)  : ORIGIN = 0x00000000, LENGTH = 128K
  RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

SECTIONS
{
	.text :
    {
		*(.isr_vector)
        *(.text*)

        *(.rodata*)

		. = ALIGN(4);
		__etext = .;
    } > ROM

    .data :
    {
		__data_start__ = .;
        *(.data*);
		*(.sdata*)

		. = ALIGN(4);
		/* All data end */
		__data_end__ = .;

		/* Configure global pointer: https://www.sifive.com/blog/all-aboard-part-3-linker-relaxation-in-riscv-toolchain */
		. = ALIGN(4);
		PROVIDE( __global_pointer$ = . + 0x800 );
    } > RAM AT> ROM

    /* .bss section which is used for uninitialized data */
	.bss :
	{
		. = ALIGN(4);
		__bss_start__ = .;
		*(.bss*)
		*(COMMON)
		. = ALIGN(4);
		__bss_end__ = .;
	} > RAM

	end = .;
}

