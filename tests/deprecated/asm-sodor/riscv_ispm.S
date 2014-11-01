# Temp test for ld/st with ISPM

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN

        li x28, 2
        la x2, setp 
        la x3, setf
        lw x4, 0(x2) # Load inst at setp
        nop
        nop
        nop
        nop
        li x5, 3
        addi x28, x28, 1
        bne x5, x28, fail # Inst at setp shouldn't have run yet.
        sw x4, 0(x3) # Modify inst from inf to setp
        nop
        nop
        nop
        nop
setf:   j fail 
        li x5, 3
        beq x5, x28, fail
        

        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END

setp:   li x28, 1

#        TEST_RISCV_BEGIN
#        TEST_STATS_BEGIN
#
#        addi x28, x0, 1
#        la x1, inf
#        li x2, 0x13
#        sw x2, 0(x1)
#        nop
#        nop
#        nop
#        nop
#        nop
#        nop
#inf:    beq x0, x0, inf
#
#        TEST_STATS_END
#        TEST_PASSFAIL
#        TEST_RISCV_END
