.section .text
.globl _start
.type _start,@function

_start:
    // set stack pointer
    li sp, 0x2001F200		// Adjust for 128KB DSPM (up to 0x2001F400).

    // Set the global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // jump to Reset_Handler
    call Reset_Handler
