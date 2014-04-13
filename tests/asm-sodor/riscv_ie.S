# Temp test for ld/st with ISPM

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN

        li x28, 2
        la x2, handler
        mtpcr x2, PCR_EVEC // Set evec with address of handler.
        GT_L
        GT_H
        addi x2, x2, 500
        IE_E
        #IE_D
        TS
#inf:    beq x0, x0, inf
        j fail
# test if exception occurs immediately.
        addi x28, x0, 1
        GT_L
        GT_H
        IE_E
        TS
        TS


        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END

handler:
        mfpcr x2, PCR_EPC // Get next PC after exception.
        addi x2, x2, 4
        jalr.j x0, x2, 0


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
