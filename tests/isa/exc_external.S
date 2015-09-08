#*****************************************************************************
# exc_external.S
#-----------------------------------------------------------------------------
#
# Test external interrupt.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # set location of interrupt handler
  la a0, int_handler
  csrw evec, a0

  li TESTNUM, 2
  li a2, 2
  # trigger external interrupt
  csrr a0, frm
  # interrupts should be disabled
  nop
  nop
  nop
  nop
  nop
  li a2, 3
  # enable interrupts
  csrsi status, 16
  # interrupt should occur
  j fail
  # interrupt handler should return here
  j pass

  TEST_PASSFAIL

int_handler:
  # should npt interrupt immediately
  li TESTNUM, 3
  bne a2, TESTNUM, fail
  # check cause
  li TESTNUM, 4
  li a1, CAUSE_EXTERNAL_INT
  csrr a0, cause
  bne a0, a1, fail
  # return to pass
  csrr a0, epc
  jalr x0, a0, 4

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
