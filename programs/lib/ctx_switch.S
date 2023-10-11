/**
 * FlexPRET's context switch mechanism
 *
 */

#include "flexpret_csrs.h"

.section .text
.globl thread_ctx_switch_store
.type thread_ctx_switch_store,@function

thread_ctx_switch_store:
    // Get a0 as the address of the contexts variable
    .option push
    .option norelax
    la a0, contexts
    .option pop

    // Get status register
    csrr a1, CSR_STATUS

    // Store it in memory
    sw a1,  (31 * 4)(a0)
    
    // TODO: Interrupt may occur before this. Should be cleared immediately
    //       upon entering the function...

    // Clear the interrupt bit
    csrci CSR_STATUS, 0x10

    // Get thread ID
    csrr a1, CSR_HARTID

    // Multiply it by offset, which is 32 * 4 = 2^5 * 2^2 = 2^7
    slli a1, a1, 7

    // Add the offset to a0
    add a0, a0, a1
    
    // Store all registers
    // x0 is hard-wired to zero so no reason to store it
    sw x1,  ( 0 * 4)(a0)
    sw x2,  ( 1 * 4)(a0)
    sw x3,  ( 2 * 4)(a0)
    sw x4,  ( 3 * 4)(a0)
    sw x5,  ( 4 * 4)(a0)
    sw x6,  ( 5 * 4)(a0)
    sw x7,  ( 6 * 4)(a0)
    sw x8,  ( 7 * 4)(a0)
    sw x9,  ( 8 * 4)(a0)
    sw x10, ( 9 * 4)(a0)
    sw x11, (10 * 4)(a0)
    sw x12, (11 * 4)(a0)
    sw x13, (12 * 4)(a0)
    sw x14, (13 * 4)(a0)
    sw x15, (14 * 4)(a0)
    sw x16, (15 * 4)(a0)
    sw x17, (16 * 4)(a0)
    sw x18, (17 * 4)(a0)
    sw x19, (18 * 4)(a0)
    sw x20, (19 * 4)(a0)
    sw x21, (20 * 4)(a0)
    sw x22, (21 * 4)(a0)
    sw x23, (22 * 4)(a0)
    sw x24, (23 * 4)(a0)
    sw x25, (24 * 4)(a0)
    sw x26, (25 * 4)(a0)
    sw x27, (26 * 4)(a0)
    sw x28, (27 * 4)(a0)
    sw x29, (28 * 4)(a0)
    sw x30, (29 * 4)(a0)
    sw x31, (30 * 4)(a0)

    j fp_exception_handler

.globl thread_ctx_switch_load
.type thread_ctx_switch_load,@function

thread_ctx_switch_load:
    .option push
    .option norelax
    la a0, contexts
    .option pop
    
    // Load all registers except the a0 itself
    // x0 is hard-wired to zero so no reason to store it
    lw x1,  ( 0 * 4)(a0)
    lw x2,  ( 1 * 4)(a0)
    lw x3,  ( 2 * 4)(a0)
    lw x4,  ( 3 * 4)(a0)
    lw x5,  ( 4 * 4)(a0)
    lw x6,  ( 5 * 4)(a0)
    lw x7,  ( 6 * 4)(a0)
    lw x8,  ( 7 * 4)(a0)
    lw x9,  ( 8 * 4)(a0)
    // Skip x10 = a0 since it is in use
    // Skip x11 = a1 since we wil use it soon
    lw x12, (11 * 4)(a0)
    lw x13, (12 * 4)(a0)
    lw x14, (13 * 4)(a0)
    lw x15, (14 * 4)(a0)
    lw x16, (15 * 4)(a0)
    lw x17, (16 * 4)(a0)
    lw x18, (17 * 4)(a0)
    lw x19, (18 * 4)(a0)
    lw x20, (19 * 4)(a0)
    lw x21, (20 * 4)(a0)
    lw x22, (21 * 4)(a0)
    lw x23, (22 * 4)(a0)
    lw x24, (23 * 4)(a0)
    lw x25, (24 * 4)(a0)
    lw x26, (25 * 4)(a0)
    lw x27, (26 * 4)(a0)
    lw x28, (27 * 4)(a0)
    lw x29, (28 * 4)(a0)
    lw x30, (29 * 4)(a0)
    lw x31, (30 * 4)(a0)

    // Load the previously used status register
    lw a1,  (31 * 4)(a0)

    // Write the register and set the interrupt bit again
    csrw CSR_STATUS, a1
    csrwi CSR_STATUS, 0x10
    
    // Load the x10 = a0 register
    lw x10, (9 * 4)(a0)

    // Load the x11 = a0 register
    lw x11, (10 * 4)(a0)

    ret
