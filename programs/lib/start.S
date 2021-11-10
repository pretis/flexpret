.section .text
.globl _start
.type _start,@function

_start:
  // set stack pointer
  li sp, 0x20001000

  .option push
  .option norelax
  la gp, __global_pointer$
  .option pop

  // set argc, argv
  li a0, 0
  li a1, 0

  // jump to main
  call main
