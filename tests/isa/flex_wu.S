#*****************************************************************************
# flex_gpio.S
#-----------------------------------------------------------------------------
#
# Test CSRRx and CSRRxI instructions.

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32S
RVTEST_CODE_BEGIN

# see include/flexpret_timing.h
# get_time: csrr a0, time
# wait_until: csrw compare, a0; TI_WU

li a2, 11
# get current time
csrr a0, CSR_CLOCK
# set compare register to this time, should be immediately expired
csrw compare, a0
# wait until should execute once and proceed
TI_WU
# instruction following wait until only executes once
addi a2, a2, 22
# now increment to time 1000ns in future
addi a0, a0, 1000
# should expire later
csrw compare, a0
# wait until should wait about 1000ns
TI_WU
# instruction following wait until only executes once
addi a2, a2, 33
# get current time
csrr a1, CSR_CLOCK
# test if waited
li TESTNUM, 2
bgeu a0, a1, fail
# test that following instructions only executed once
li TESTNUM, 3
addi a2, a2, -66
bne x0, a2, fail


TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
