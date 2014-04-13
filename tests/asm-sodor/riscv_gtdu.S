# Temp test for ld/st with ISPM

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN

        li x28, 2

# make sure delay happens
        GT_L
        GT_H
        addi x2, x2, 150
        move x4, x2
        DU
        GT_L
        bge x4, x2, fail

        addi x28, x0, 1

        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END


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
