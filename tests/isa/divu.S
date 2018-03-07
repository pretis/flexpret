#*****************************************************************************
# divu.S
#-----------------------------------------------------------------------------
#
# Test divu instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  #-------------------------------------------------------------
  # Arithmetic tests
  #-------------------------------------------------------------

  TEST_RR_OP(2,  divu, 0x00000000, 0x00000000, 0x00000001 );
  TEST_RR_OP(3,  divu, 0x00000003, 0x00000020, 0x00000009 );
  TEST_RR_OP(4,  divu, 0x00000004, 0x00000020, 0x00000008 );

  TEST_RR_OP(5,  divu, 0x00000001, 0xffffffff, 0xfffffffe );
  TEST_RR_OP(6,  divu, 0x00000000, 0xfffffffd, 0xffffffff );
  TEST_RR_OP(7,  divu, 0x00000000, 0xff697e5e, 0xfffffff3 );

  TEST_RR_OP(8,  divu, 0x7fffffff, 0xffffffff, 0x00000002 );
  TEST_RR_OP(9,  divu, 0xfffffffd, 0xfffffffd, 0x00000001 );
  TEST_RR_OP(10, divu, 0x13a5a742, 0xff697e5e, 0x0000000d );

  #-------------------------------------------------------------
  # Source/Destination tests
  #-------------------------------------------------------------

  TEST_RR_SRC1_EQ_DEST( 11, divu, 9, 18, 2 );
  TEST_RR_SRC2_EQ_DEST( 12, divu, 10, 31, 3 );
  TEST_RR_SRC12_EQ_DEST( 13, divu, 1, 18 );

  #-------------------------------------------------------------
  # Bypassing tests
  #-------------------------------------------------------------

  TEST_RR_DEST_BYPASS( 14, 0, divu, 9,  18, 2  );
  TEST_RR_DEST_BYPASS( 15, 1, divu, 10, 31, 3  );
  TEST_RR_DEST_BYPASS( 16, 2, divu, 3,  33, 11 );

  TEST_RR_SRC12_BYPASS( 17, 0, 0, divu, 9,  18, 2  );
  TEST_RR_SRC12_BYPASS( 18, 0, 1, divu, 10, 31, 3  );
  TEST_RR_SRC12_BYPASS( 19, 0, 2, divu, 3,  33, 11 );
  TEST_RR_SRC12_BYPASS( 20, 1, 0, divu, 9,  18, 2  );
  TEST_RR_SRC12_BYPASS( 21, 1, 1, divu, 10, 31, 3  );
  TEST_RR_SRC12_BYPASS( 22, 2, 0, divu, 3,  33, 11 );

  TEST_RR_SRC21_BYPASS( 23, 0, 0, divu, 9,  18, 2  );
  TEST_RR_SRC21_BYPASS( 24, 0, 1, divu, 10, 31, 3  );
  TEST_RR_SRC21_BYPASS( 25, 0, 2, divu, 3,  33, 11 );
  TEST_RR_SRC21_BYPASS( 26, 1, 0, divu, 9,  18, 2  );
  TEST_RR_SRC21_BYPASS( 27, 1, 1, divu, 10, 31, 3  );
  TEST_RR_SRC21_BYPASS( 28, 2, 0, divu, 3,  33, 11 );

  TEST_RR_ZEROSRC1( 29, divu, 0, 31 );
#  TEST_RR_ZEROSRC2( 30, divu, 0, 32 ); # division by zero
#  TEST_RR_ZEROSRC12( 31, divu, 0 ); # division by zero
  TEST_RR_ZERODEST( 32, divu, 33, 34 );

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

RVTEST_DATA_END
