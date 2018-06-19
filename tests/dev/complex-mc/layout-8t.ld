OUTPUT_ARCH("riscv")

/* text */
stext = 0x2000000;
sdata = 0x4000000;
/* data */
shared_size = 0x0;
t0_size = 0x4000;
t1_size = 0x4000;
t2_size = 0x4000;
t3_size = 0x4000;
t4_size = 0x4000;
t5_size = 0x4000;
t6_size = 0x4000;
t7_size = 0x4000; 
/* t0_size = 0x1000; */
/* t1_size = 0x1000; */
/* t2_size = 0x1000; */
/* t3_size = 0x1000; */
/* t4_size = 0x1000; */
/* t5_size = 0x1000; */
/* t6_size = 0x1000; */
/* t7_size = 0x1000; */ 

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
      t2_edata = ABSOLUTE(.) - 4;
      t3_sdata = ABSOLUTE(.);
      *t3*(.rodata* .data*);
      t3_sbss = ABSOLUTE(.);
      *t3*(.bss*);
      t3_ebss = ABSOLUTE(.);
      lc += t3_size;
      . = lc;
      t3_edata = ABSOLUTE(.) - 4;
      t4_sdata = ABSOLUTE(.);
      *t4*(.rodata* .data*);
      t4_sbss = ABSOLUTE(.);
      *t4*(.bss*);
      t4_ebss = ABSOLUTE(.);
      lc += t4_size;
      . = lc;
      t4_edata = ABSOLUTE(.) - 4;
      t5_sdata = ABSOLUTE(.);
      *t5*(.rodata* .data*);
      t5_sbss = ABSOLUTE(.);
      *t5*(.bss*);
      t5_ebss = ABSOLUTE(.);
      lc += t5_size;
      . = lc;
      t5_edata = ABSOLUTE(.) - 4;
      t6_sdata = ABSOLUTE(.);
      *t6*(.rodata* .data*);
      t6_sbss = ABSOLUTE(.);
      *t6*(.bss*);
      t6_ebss = ABSOLUTE(.);
      lc += t6_size;
      . = lc;
      t6_edata = ABSOLUTE(.) - 4;
      t7_sdata = ABSOLUTE(.);
      *t7*(.rodata* .data*);
      t7_sbss = ABSOLUTE(.);
      *t7*(.bss*);
      t7_ebss = ABSOLUTE(.);
      lc += t7_size;
      t7_edata = ABSOLUTE(lc) - 4;
  }

}
