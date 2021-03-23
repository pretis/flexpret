/* Basic linker script for .text at TEXT_START_ADDR and .data; .bss at DATA_START_ADDR */
OUTPUT_ARCH("riscv")

SECTIONS
{
  /* text: Code segment */
  . = TEXT_START_ADDR;
  .text :
  {
    *startup.o (.text);
    *(.text*);
  }
  /* data: Initialized data segment */
  . = DATA_START_ADDR;
  .data :
  {
    *startup.o (.data);
    *(.rodata*);
    *(.sdata*);
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
