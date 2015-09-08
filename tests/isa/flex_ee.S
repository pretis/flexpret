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
# get_time: csrr a0, CSR_CLOCK
# interrupt_expire: csrw compare, a0; TI_IE
# exception_expire: csrw compare, a0; TI_EE
# delay_until: csrw compare, a0; TI_DU

# set address for exception handling
la a1, evec1
csrw evec, a1
# number to check control flow
li a2, 11
# get current time
csrr a0, CSR_CLOCK
# set compare register to this time, should be immediately expired
csrw compare, a0
# exception_expire should expire immediately and go to evec1
TI_EE
# instruction following should only execute once
epc1:
addi a2, a2, 22
# set address for exception handling
la a1, evec2
csrw evec, a1
# now increment to time 4000ns in future
li a1, 4000
add a0, a0, a1
# should expire later
csrw compare, a0
# exception_expire should not expire immediately
TI_EE
# instruction following delay until only executes once
addi a2, a2, 10
# get current time
csrr a1, CSR_CLOCK
# should not have expired
li TESTNUM, 5
bgeu a1, a0, fail
# test that following instructions only executed once
li TESTNUM, 6
addi a2, a2, -76
bne x0, a2, fail
# wait for expiration
1: csrr a1, CSR_CLOCK
addi a2, a2, 1
bgeu a0, a1, 1b

TEST_PASSFAIL

evec1:
  # instruction following exception_expire should not execute
  li TESTNUM, 2
  li a3, 11
  bne a3, a2, fail
  # cause should be set to 0xD
  li TESTNUM, 3
  li a3, CAUSE_EE
  csrr a4, cause
  bne a3, a4, fail
  # epc should be epc1
  li TESTNUM, 4
  la a3, epc1
  csrr a4, epc
  bne a3, a4, fail
  # modify value
  addi a2, a2, 33
  # return
  jalr x0, a4, 0

evec2:
  # a2 should have incremented several times
  li TESTNUM, 7
  li a1, 5
  bltu a2, a1, fail
  csrr a4, epc
  jalr x0, a4, 0

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
