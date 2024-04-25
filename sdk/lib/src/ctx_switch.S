/**
 * FlexPRET's context switch mechanism
 *
 * Author: Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 */

#include <flexpret/csrs.h>

.section .text
.globl thread_ctx_switch_store
.type thread_ctx_switch_store,@function

/**
 * The contexts variable is declared as
 *
 * struct thread_ctx_t contexts[NUM_THREADS];
 *
 * where the thread_ctx_t is aligned to 32 words for the sake of simplicity.
 * Getting the context for a specific thread is then calculating the offset;
 * see the macro itself for details.
 */
.macro getContexts
    /**
     * Get a0 as the address of the contexts variable - use norelax option to
     * ensure the assembler does not optimize la (= auipc + addi) to a reference
     * relative to the global pointer (gp).
     * 
     * Seeing as gp is stored and loaded again, we should assume it might have a
     * different value when we load. So it is safer to use an absolute address.
     */

    .option push
    .option norelax
    la a0, contexts
    .option pop

    // Get thread ID
    csrr a1, CSR_HARTID

    // Multiply it by offset, which is 32 * 4 = 2^5 * 2^2 = 2^7
    slli a1, a1, 7

    // Add the offset to the pointer a0
    add a0, a0, a1
.endm

thread_ctx_switch_store:
    // Disable interrupts
    csrci CSR_STATUS, 0x10

    // Push a0, a1 to stack
    addi sp, sp, -32
    sw a0, 28(sp)
    sw a1, 24(sp)

    getContexts

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
    getContexts

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
    // Skip x10 = a0 since it is on the stack
    // Skip x11 = a1 since it is on the stack
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
    
    // Load a0, a1 from stack
    lw a0, 28(sp)
    lw a1, 24(sp)
    addi sp, sp, 32

    // Clear interrupt pending bit
    csrci CSR_STATUS, 0x08

    // Write the register and set the interrupt bit again
    csrwi CSR_STATUS, 0x10

    // Will jump to the address found in MEPC = Machine (mode) exception PC
    mret
