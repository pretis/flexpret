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

  // True/False
  val T = Bool(true)
  val F = Bool(false)
  
  // Branch/Jump address base
  val BASE_WI = 1
  val BASE_PC  = UInt(0, 1)
  val BASE_RS1 = UInt(1, 1)
  //val BASE_X   = UInt(0, 1)
  val BASE_X   = Bits("b?", 1)
  
  // ALU op1 select
  val OP1_WI = 2
  val OP1_PC  = UInt(0, 2)
  val OP1_RS1 = UInt(1, 2)
  val OP1_0   = UInt(2, 2)
  //val OP1_X   = UInt(1, 2)
  val OP1_X   = Bits("b??", 2)
 
  // ALU op2 select
  val OP2_WI = 2
  val OP2_IMM = UInt(0, 3)
  val OP2_RS2 = UInt(1, 3)
  val OP2_4   = UInt(2, 3)
  val OP2_0   = UInt(3, 3)
  //val OP2_X   = UInt(1, 3)
  val OP2_X   = Bits("b???", 3)

  // Immediate
  val IMM_WI = 3
  val IMM_S = UInt(0, 3)
  val IMM_B = UInt(1, 3)
  val IMM_U = UInt(2, 3)
  val IMM_J = UInt(3, 3)
  val IMM_I = UInt(4, 3)
  val IMM_Z = UInt(5, 3)
  //val IMM_X = UInt(0, 3) 
  val IMM_X = Bits("b???", 3)

  // ALU operation types
  val ALU_WI = 4
  val ALU_ADD    = UInt( 0, 4)
  val ALU_SLL    = UInt( 1, 4)
  val ALU_XOR    = UInt( 4, 4)
  val ALU_SRL    = UInt( 5, 4)
  val ALU_OR     = UInt( 6, 4)
  val ALU_AND    = UInt( 7, 4)
  val ALU_SUB    = UInt( 8, 4)
  val ALU_SLT    = UInt(10, 4)
  val ALU_SLTU   = UInt(11, 4)
  val ALU_SRA    = UInt(13, 4)
  // Branching conditions
  val ALU_SEQ    = UInt(9, 4)
  val ALU_SNE    = UInt(12, 4)
  val ALU_SGE    = UInt(14, 4)
  val ALU_SGEU   = UInt(15, 4)
  //val ALU_X      = UInt(0, 4)
  val ALU_X      = Bits("b????", 4)
  
  // rd from execute stage select
  val EXE_RD_WI = 1
  val EXE_RD_ALU = UInt(0, 1)
  val EXE_RD_CSR = UInt(1, 1)
  //val EXE_RD_X   = UInt(0, 1)
  val EXE_RD_X   = Bits("b?", 1)
  
  val CSR_WI = 2
  val CSR_W = UInt(0, 2)
  val CSR_S = UInt(1, 2)
  val CSR_C = UInt(2, 2)
  val CSR_F = UInt(3, 2)
  
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
  val MEM_F   = UInt(12, 4)

  //val MUL_L   = UInt(0, 2)
  //val MUL_H   = UInt(1, 2)
  //val MUL_HSU = UInt(2, 2)
  //val MUL_HU  = UInt(3, 2)
  //val MUL_X   = UInt(0, 2)
  //val MUL_X   = Bits("b??", 2)
  
  // rd from memory stage select
  val MEM_RD_WI = 1
  val MEM_RD_REG = UInt(0, 1)
  val MEM_RD_MEM = UInt(1, 1)
  //val MEM_RD_X   = UInt(0, 1)
  val MEM_RD_X   = Bits("b?", 1)
  
  
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
  val SLOT_S = UInt(14, 4)
  val SLOT_D = UInt(15, 4)

  // thread modes
  val TMODE_WI = 2
  val TMODE_HA = UInt(0, 2)
  val TMODE_HZ = UInt(1, 2)
  val TMODE_SA = UInt(2, 2)
  val TMODE_SZ = UInt(3, 2)
  val TMODE_AND_A = UInt(2, 2)
  val TMODE_OR_Z  = UInt(1, 2)

  val CAUSE_X = UInt(0, 4)

  // Memory Space
  val ADDR_PC_INIT = Bits("h02000000", 32)
  val ADDR_EVEC_INIT = Bits("h02000000", 32)
  val ADDR_ISPM_BITS = 7
  val ADDR_ISPM_VAL = Bits("b0000_001", ADDR_ISPM_BITS)
  val ADDR_DSPM_BITS = 7
  val ADDR_DSPM_VAL = Bits("b0000_010", ADDR_DSPM_BITS)
  // TODO: bus address space



}
