/******************************************************************************
File: constants.scala
Description: Constant values for parameters, control signals, and RISC-V ISA.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._

object FlexpretConstants
{

  // ISA
  val REG_ADDR_BITS = 5

  // ************************************************************
  // Decoded from instruction

  // true/false
  val T = Bool(true)
  val F = Bool(false)
  val X = Bits("b?", 1)
  
  // immediate
  val IMM_WI = 3
  val IMM_S  = UInt(0, 3)
  val IMM_B  = UInt(1, 3)
  val IMM_U  = UInt(2, 3)
  val IMM_J  = UInt(3, 3)
  val IMM_I  = UInt(4, 3)
  val IMM_Z  = UInt(5, 3)
  val IMM_X  = Bits("b???", 3)

  // ALU op1 select
  val OP1_WI = 2
  val OP1_PC  = UInt(0, 2)
  val OP1_RS1 = UInt(1, 2)
  val OP1_0   = UInt(2, 2)
  val OP1_X   = Bits("b??", 2)
 
  // ALU op2 select
  val OP2_WI = 2
  val OP2_IMM = UInt(0, 2)
  val OP2_RS2 = UInt(1, 2)
  val OP2_0   = UInt(2, 2)
  val OP2_4   = UInt(3, 2) // only needed for WU
  val OP2_X   = Bits("b??", 2)

  // ALU operation types
  val ALU_WI = 4
  val ALU_ADD  = UInt( 0, 4)
  val ALU_SLL  = UInt( 1, 4)
  val ALU_XOR  = UInt( 4, 4)
  val ALU_SRL  = UInt( 5, 4)
  val ALU_OR   = UInt( 6, 4)
  val ALU_AND  = UInt( 7, 4)
  val ALU_SUB  = UInt( 8, 4)
  val ALU_SLT  = UInt(10, 4)
  val ALU_SLTU = UInt(11, 4)
  val ALU_SRA  = UInt(13, 4)
  val ALU_X    = Bits("b????", 4)
  
  // branch condition
  val BR_WI = 3
  val BR_EQ  = UInt(0, 3)
  val BR_NE  = UInt(1, 3)
  val BR_LT  = UInt(2, 3)
  val BR_GE  = UInt(3, 3)
  val BR_LTU = UInt(4, 3)
  val BR_GEU = UInt(5, 3)
  val BR_X   = Bits("b???", 3)
 
  // CSR types
  val CSR_WI = 2
  val CSR_W = UInt(1, 2)
  val CSR_S = UInt(2, 2)
  val CSR_C = UInt(3, 2)
  val CSR_X = Bits("b??", 2)
  
  // rd from execute stage select
  val EXE_RD_WI = 2
  val EXE_RD_ALU = UInt(0, 2)
  val EXE_RD_CSR = UInt(1, 2)
  val EXE_RD_PC4 = UInt(2, 2)
  val EXE_RD_X   = Bits("b??", 2)
  
  // memory load/store operation types
  val MEM_WI = 4
  val MEM_LB  = UInt(0,  4)
  val MEM_LH  = UInt(1,  4)
  val MEM_LW  = UInt(2,  4)
  val MEM_LBU = UInt(4,  4)
  val MEM_LHU = UInt(5,  4)
  val MEM_SB  = UInt(8,  4)
  val MEM_SH  = UInt(9,  4)
  val MEM_SW  = UInt(10, 4)
  val MEM_X   = Bits("b????", 4)

  val MUL_WI = 2
  val MUL_L   = UInt(0, 2)
  val MUL_H   = UInt(1, 2)
  val MUL_HSU = UInt(2, 2)
  val MUL_HU  = UInt(3, 2)
  val MUL_X   = Bits("b??", 2)
  
  // rd from memory stage select
  val MEM_RD_WI = 2
  val MEM_RD_REG = UInt(0, 2)
  val MEM_RD_MEM = UInt(1, 2)
  val MEM_RD_MUL = UInt(2, 2)
  val MEM_RD_X   = Bits("b??", 2)
  
  
  // ************************************************************
  // Determined by control

  // next PCs select
  val NPC_WI = 2
  val NPC_PCREG = UInt(0, 2)
  val NPC_PLUS4 = UInt(1, 2)
  val NPC_BRJMP = UInt(2, 2)
  val NPC_EVEC  = UInt(3, 2)

  // rs1 source select
  val RS1_WI = 2
  val RS1_DEC = UInt(0, 2)
  val RS1_EXE = UInt(1, 2)
  val RS1_MEM = UInt(2, 2)
  val RS1_WB  = UInt(3, 2)

  // rs2 source select
  val RS2_WI = 2
  val RS2_DEC = UInt(0, 2)
  val RS2_EXE = UInt(1, 2)
  val RS2_MEM = UInt(2, 2)
  val RS2_WB  = UInt(3, 2)
 
  // ************************************************************
  // Constants
  
  // thread scheduling slots
  val SLOT_WI = 4
  val SLOT_T0 = UInt(0, 4)
  val SLOT_T1 = UInt(1, 4)
  val SLOT_T2 = UInt(2, 4)
  val SLOT_T3 = UInt(3, 4)
  val SLOT_T4 = UInt(4, 4)
  val SLOT_T5 = UInt(5, 4)
  val SLOT_T6 = UInt(6, 4)
  val SLOT_T7 = UInt(7, 4)
  val SLOT_S  = UInt(14, 4)
  val SLOT_D  = UInt(15, 4)

  // thread modes
  val TMODE_WI = 2
  val TMODE_HA = UInt(0, 2)
  val TMODE_HZ = UInt(1, 2)
  val TMODE_SA = UInt(2, 2)
  val TMODE_SZ = UInt(3, 2)
  val TMODE_AND_A = UInt(2, 2)
  val TMODE_OR_Z  = UInt(1, 2)

  // timer modes
  val TIMER_WI = 2
  val TIMER_OFF   = UInt(0, 2)
  val TIMER_DU_WU = UInt(1, 2)
  val TIMER_IE    = UInt(2, 2)
  val TIMER_EE    = UInt(3, 2)

  // memory space
  val ADDR_PC_INIT   = Bits("h00000000", 32)
  val ADDR_EVEC_INIT = Bits("h00000000", 32)
  val ADDR_ISPM_BITS = 3
  val ADDR_ISPM_VAL  = Bits("b000", ADDR_ISPM_BITS)
  val ADDR_DSPM_BITS = 3
  val ADDR_DSPM_VAL  = Bits("b001", ADDR_DSPM_BITS)
  val ADDR_BUS_BITS  = 2
  val ADDR_BUS_VAL   = Bits("b01", ADDR_BUS_BITS)
  
  // memory protection
  val MEMP_WI = 4
  val MEMP_T0 = UInt(0, 4)
  val MEMP_T1 = UInt(1, 4)
  val MEMP_T2 = UInt(2, 4)
  val MEMP_T3 = UInt(3, 4)
  val MEMP_T4 = UInt(4, 4)
  val MEMP_T5 = UInt(5, 4)
  val MEMP_T6 = UInt(6, 4)
  val MEMP_T7 = UInt(7, 4)
  val MEMP_SH = UInt(8, 4) // shared
  val MEMP_RO = UInt(12, 4) // read-only

  // exceptions
  val CAUSE_WI = 5


}
