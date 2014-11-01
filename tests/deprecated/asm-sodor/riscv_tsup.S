# Temp test for supervisory mode

#include "test_macros.h"

        TEST_RISCV_BEGIN
        //TEST_STATS_BEGIN

        addi x28, x0, 1
        
        mtpcr x2, PCR_TSUP
        # these instructions should have no effect.
        li x2, -1
        mtpcr x2, PCR_SCHEDULE
        mtpcr x2, PCR_TMODES

        TEST_PASSFAIL
        TEST_RISCV_END
