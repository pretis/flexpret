# See LICENSE for license details.

#*****************************************************************************
# illegal.S
#-----------------------------------------------------------------------------
#
# Test illegal instruction trap.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

#ifdef __MACHINE_MODE
  #define sscratch mscratch
  #define sstatus mstatus
  #define scause mcause
  #define sepc mepc
  #define stvec_handler mtvec_handler
#endif

  la a0, stvec_handler
  csrw evec, a0

  li TESTNUM, 2
  .word 0
  j fail

  j pass

  TEST_PASSFAIL

stvec_handler:
  li a1, CAUSE_ILLEGAL_INSTRUCTION
  csrr a0, scause
  bne a0, a1, fail
  csrr a0, sepc
  jalr x0, a0, 8
  #addi a0, a0, 8
  #csrw sepc, a0
  #sret

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
