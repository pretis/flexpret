.section .text
.globl _start
.type _start,@function

_start:
    // set stack pointer
    li sp, 0x2003E800		// Adjust for a 256KB DSPM (up to 0x2003E800).

    // Set the global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // jump to Reset_Handler
    call Reset_Handler
