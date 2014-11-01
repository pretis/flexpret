# Temp test for supervisory mode

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN


        # Write to shared.
        li x28, 2
        la x2, shared
        li x3, 0xbeef0001
        sw x3, 0(x2)
        lw x4, 0(x2)
        bne x3, x4, fail 
        
        # Write to private.
        li x28, 3
        la x2, private
        li x3, 0xbeef0002
        sw x3, 0(x2)
        lw x4, 0(x2)
        bne x3, x4, fail 

        li x2, 0
        mtpcr x2, PCR_SHARED
        mtpcr x2, PCR_PRIV_L
        mtpcr x2, PCR_PRIV_H

        # Block write to shared.
        li x28, 4
        la x2, shared
        li x3, 0xbeef0003
        sw x3, 0(x2)
        lw x4, 0(x2)
        li x3, 0xbeef0001
        bne x3, x4, fail 
        
        # Block write to private.
        li x28, 5
        la x2, private
        li x3, 0xbeef0004
        sw x3, 0(x2)
        lw x4, 0(x2)
        li x3, 0xbeef0002
        bne x3, x4, fail 
        addi x28, x0, 1
        
        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END

.data
.skip 1024
shared: .word 0xdeadbeef
.skip 1020
private: .word 0xdeadbeef
