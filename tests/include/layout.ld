OUTPUT_ARCH("riscv")

SECTIONS
{
  /* text: Code segment */
  . = TEXT_START_ADDR;
  .text :
  {
    *(.text*);
  }
  /* data: Initialized data segment */
  . = DATA_START_ADDR;
  .data :
  {
    *(.rodata*);
    *(.data*);
  }
  bss_start = .;
  /* bss: Uninitialized data segment */
  .bss :
  {
    *(.bss*);
  }
  bss_end = .;
  bss_size = bss_end - bss_start;

}
