#*****************************************************************************
# riscv_mulh.S
#-----------------------------------------------------------------------------
#
# Test mulh instruction.
#

#include "test_macros.h"

        TEST_RISCV_BEGIN
        TEST_STATS_BEGIN

        #-------------------------------------------------------------
        # Arithmetic tests
        #-------------------------------------------------------------

        TEST_RR_OP( 2,  mulh, 0x00000000, 0x00000000, 0x00000000 );
        TEST_RR_OP( 3,  mulh, 0x00000000, 0x00000001, 0x00000001 );
        TEST_RR_OP( 4,  mulh, 0x00000000, 0x00000003, 0x00000007 );

        TEST_RR_OP( 5,  mulh, 0x0000000000000000, 0x0000000000000000, 0xffffffffffff8000 );
        TEST_RR_OP( 6,  mulh, 0x0000000000000000, 0xffffffff80000000, 0x00000000 );
#        TEST_RR_OP( 7,  mulh, 0x0000000000000000, 0xffffffff80000000, 0xffffffffffff8000 );

        #-------------------------------------------------------------
        # Source/Destination tests
        #-------------------------------------------------------------

        TEST_RR_SRC1_EQ_DEST( 8, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_SRC2_EQ_DEST( 9, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_SRC12_EQ_DEST( 10, mulh, 169, 13<<16 );

        #-------------------------------------------------------------
        # Bypassing tests
        #-------------------------------------------------------------

        TEST_RR_DEST_BYPASS( 11, 0, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_DEST_BYPASS( 12, 1, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_DEST_BYPASS( 13, 2, mulh, 165, 15<<16, 11<<16 );

        TEST_RR_SRC12_BYPASS( 14, 0, 0, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_SRC12_BYPASS( 15, 0, 1, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_SRC12_BYPASS( 16, 0, 2, mulh, 165, 15<<16, 11<<16 );
        TEST_RR_SRC12_BYPASS( 17, 1, 0, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_SRC12_BYPASS( 18, 1, 1, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_SRC12_BYPASS( 19, 2, 0, mulh, 165, 15<<16, 11<<16 );

        TEST_RR_SRC21_BYPASS( 20, 0, 0, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_SRC21_BYPASS( 21, 0, 1, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_SRC21_BYPASS( 22, 0, 2, mulh, 165, 15<<16, 11<<16 );
        TEST_RR_SRC21_BYPASS( 23, 1, 0, mulh, 143, 13<<16, 11<<16 );
        TEST_RR_SRC21_BYPASS( 24, 1, 1, mulh, 154, 14<<16, 11<<16 );
        TEST_RR_SRC21_BYPASS( 25, 2, 0, mulh, 165, 15<<16, 11<<16 );

        TEST_RR_ZEROSRC1( 26, mulh, 0, 31<<16 );
        TEST_RR_ZEROSRC2( 27, mulh, 0, 32<<16 );
        TEST_RR_ZEROSRC12( 28, mulh, 0 );
        TEST_RR_ZERODEST( 29, mulh, 33<<16, 34<<16 );

        TEST_STATS_END
        TEST_PASSFAIL
        TEST_RISCV_END
