/**
 * FlexPRET's startup code in RISC-V assembly
 * Authors:
 * - Edward Wang
 * - Shaokai Lin
 * - Samuel Berkun
 */

.section .text
.globl _start
.type _start,@function

.macro setHartid
    /* Store thread id at t0 */
    csrr t0, 0x50b // 0x50b = hartid CSR
.endm

.macro setStackPointer
    /* Give each thread 16KB of stack. */

    // 0x40000 = 256KiB = DSPM size
    // 0x20040000 is the maximum DSPM address.
    li sp, 0x20040000
    
    // Calculate how much to subtract
    // from the max address based on
    // thread id.
    sll t1, t0, 14 // (thread_id) * 2^14

    // Set the stack pointer.
    sub sp, sp, t1
.endm

.macro setGlobalPointer 
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
.endm

.macro setDMemProtection 
    // set all 8 memory regions to shared
    // (rather than exclusive to thread 0)
    li t1, 0x88888888
    csrw 0x50c, t1 // 0x50c = dMemProtection CSR
.endm

_start:
    setHartid
    setStackPointer
    setGlobalPointer
    setDMemProtection
    call Reset_Handler
