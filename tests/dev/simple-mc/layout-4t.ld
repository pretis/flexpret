OUTPUT_ARCH("riscv")

/* text */
stext = 0x2000000;
sdata = 0x4000000;
/* data */
shared_size = 0x0;
t0_size = 0x1000;
t1_size = 0x1000;
t2_size = 0x1000;
t3_size = 0x1000;

SECTIONS
{
  /* text: Code segment */
  . = stext;
  .text :
  {
    *(.text*);
  }

  . = sdata;
  .data :
  {
      lc = shared_size;
      . = lc;
      t0_sdata = ABSOLUTE(.);
      *t0*(.rodata* .data*);
      t0_sbss = ABSOLUTE(.);
      *t0*(.bss*);
      t0_ebss = ABSOLUTE(.);
      lc += t0_size;
      . = lc;
      t0_edata = ABSOLUTE(.) - 4;
      t1_sdata = ABSOLUTE(.);
      *t1*(.rodata* .data*);
      t1_sbss = ABSOLUTE(.);
      *t1*(.bss*);
      t1_ebss = ABSOLUTE(.);
      lc += t1_size;
      . = lc;
      t1_edata = ABSOLUTE(.) - 4;
      t2_sdata = ABSOLUTE(.);
      *t2*(.rodata* .data*);
      t2_sbss = ABSOLUTE(.);
      *t2*(.bss*);
      t2_ebss = ABSOLUTE(.);
      lc += t2_size;
      . = lc;
      t2_edata = ABSOLUTE(.);
      t3_sdata = ABSOLUTE(.);
      *t3*(.rodata* .data*);
      t3_sbss = ABSOLUTE(.);
      *t3*(.bss*);
      t3_ebss = ABSOLUTE(.);
      lc += t3_size;
      t3_edata = ABSOLUTE(lc) - 4;
  }

}
