# See LICENSE for license details.

#*****************************************************************************
# exc_priv.S
#-----------------------------------------------------------------------------
#
# Test CSR privileges
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # start in privileged mode
  la a0, evec1
  csrw evec, a0
  # out of privileged mode
  li TESTNUM, 2
  sret
  # write to privileged CSR should cause exception
  csrw evec, a0
  j fail

  j pass

  TEST_PASSFAIL

evec1:
  # check cause
  li TESTNUM, 3
  li a1, CAUSE_PRIVILEGED_INSTRUCTION
  csrr a0, cause
  bne a0, a1, fail
  # return and pass
  csrr a0, epc
  jalr x0, a0, 8

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
