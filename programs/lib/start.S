.section .text
.globl _start
.type _start,@function

_start:
  // set stack pointer
  // li sp, 0x20001000	// Only works for 16KB w/o large data section.
  li sp, 0x2001F200		// Adjust for 128KB DSPM (up to 0x2001F400).

  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop

  // set argc, argv
  li a0, 0
  li a1, 0

  // jump to main
  call main
