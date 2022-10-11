.section .text
.globl _start
.type _start,@function

.macro setStackPointer 
    li sp, 0x2003E800 // 0x3E800 = 256K
.endm

_start:
    setStackPointer	

    // Set the global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop

    // jump to Reset_Handler
    call Reset_Handler
