OUTPUT_ARCH("riscv")

SECTIONS
{
	. = 0x00000000;
	.text :
	{
		*start.o (.text);
		*(.text*);
	}

	__global_pointer$ = .;
    text_end = .;

	. = 0x20000000;
	.data :
	{
		*start.o (.data);
		*(.rodata*);
		*(.sdata*);
		*(.data*);
	}

	bss_start = .;
	.bss :
	{
		*(.bss*);
		*(.sbss*);
	}
	end = .;
	bss_size = end - bss_start;
}

