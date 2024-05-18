/**
 * FlexPRET's startup code in RISC-V assembly
 * Authors:
 * - Edward Wang
 * - Shaokai Lin
 * - Samuel Berkun
 */


#include <flexpret/internal/hwconfig.h>
#include <flexpret/swconfig.h>

.section .zero_addr_function
.globl _start
.type _start,@function

.macro setHartid
    /* Store thread id at t0 */
    csrr t0, 0x50b // 0x50b = hartid CSR
.endm

.macro setStackPointer
    la sp, __stack_start$
    
    // Calculate how much to subtract
    // from the max address based on
    // thread id and FP_STACKSIZE_BITS from flexpret_swconfig.h.
    sll t1, t0, FP_STACKSIZE_BITS // (thread_id) * 2^FP_STACKSIZE_BITS

    // Set the stack pointer.
    sub sp, sp, t1
.endm

.macro setGlobalPointer
    /**
     * The option norelax ensures that the assembler does not optimize the la
     * pseudo instruction from using an aboslute address into using an address
     * relative to the global pointer (gp). 
     * 
     * This is important because gp is not yet set.
     */
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

.macro setGpoProtection
    li t1, 0x88888888
    csrw 0x50d, t1 // 0x50c = GpoProtection CSR
.endm

_start:
    setHartid
    setStackPointer
    setGlobalPointer
    setDMemProtection
    setGpoProtection
    call Reset_Handler
