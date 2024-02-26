/******************************************************************************
File: constants.scala
Description: Constant values for parameters, control signals, and RISC-V ISA.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package Core

import chisel3._
import chisel3.util._

object FlexpretConstants
{

  // ISA
  val REG_ADDR_BITS = 5

  // ************************************************************
  // Decoded from instruction

  // true/false
  def Y = BitPat("b1")
  def N = BitPat("b0")
  val X = BitPat("b?")

  // immediate
  val IMM_WI = 3
  val IMM_S  = 0.U(3.W)
  val IMM_B  = 1.U(3.W)
  val IMM_U  = 2.U(3.W)
  val IMM_J  = 3.U(3.W)
  val IMM_I  = 4.U(3.W)
  val IMM_Z  = 5.U(3.W)
  val IMM_X  = BitPat("b???")

  // ALU op1 select
  val OP1_WI = 2
  val OP1_PC  = 0.U(2.W)
  val OP1_RS1 = 1.U(2.W)
  val OP1_0   = 2.U(2.W)
  val OP1_X   = BitPat("b??")

  // ALU op2 select
  val OP2_WI = 2
  val OP2_IMM = 0.U(2.W)
  val OP2_RS2 = 1.U(2.W)
  val OP2_0   = 2.U(2.W)
  val OP2_4   = 3.U(2.W) // only needed for WU
  val OP2_X   = BitPat("b??")

  // branch condition
  val BR_WI = 3
  val BR_EQ  = 0.U(3.W)
  val BR_NE  = 1.U(3.W)
  val BR_LT  = 2.U(3.W)
  val BR_GE  = 3.U(3.W)
  val BR_LTU = 4.U(3.W)
  val BR_GEU = 5.U(3.W)
  val BR_X   = BitPat("b???")

  // CSR types
  val CSR_WI = 2
  val CSR_W = 1.U(2.W)
  val CSR_S = 2.U(2.W)
  val CSR_C = 3.U(2.W)
  val CSR_X = BitPat("b??")

  // rd from execute stage select
  val EXE_RD_WI = 2
  val EXE_RD_ALU = 0.U(2.W)
  val EXE_RD_CSR = 1.U(2.W)
  val EXE_RD_PC4 = 2.U(2.W)
  val EXE_RD_X   = BitPat("b??")

  // memory load/store operation types
  val MEM_WI = 4
  val MEM_LB  = 0.U(4.W)
  val MEM_LH  = 1.U(4.W)
  val MEM_LW  = 2.U(4.W)
  val MEM_LBU = 4.U(4.W)
  val MEM_LHU = 5.U(4.W)
  val MEM_SB  = 8.U(4.W)
  val MEM_SH  = 9.U(4.W)
  val MEM_SW  = 1.U(4.W)
  val MEM_X   = BitPat("b????")

  val MUL_WI = 2
  val MUL_L   = 0.U(2.W)
  val MUL_H   = 1.U(2.W)
  val MUL_HSU = 2.U(2.W)
  val MUL_HU  = 3.U(2.W)
  val MUL_X   = BitPat("b??")

  // rd from memory stage select
  val MEM_RD_WI = 2
  val MEM_RD_REG = 0.U(2.W)
  val MEM_RD_MEM = 1.U(2.W)
  val MEM_RD_MUL = 2.U(2.W)
  val MEM_RD_X   = BitPat("b??")
  
  // ************************************************************
  // Determined by control

  // next PCs select
  val NPC_WI = 2
  val NPC_PCREG = 0.U(2.W)
  val NPC_PLUS4 = 1.U(2.W)
  val NPC_BRJMP = 2.U(2.W)
  val NPC_CSR   = 3.U(2.W)

  // rs1 source select
  val RS1_WI = 2
  val RS1_DEC = 0.U(2.W)
  val RS1_EXE = 1.U(2.W)
  val RS1_MEM = 2.U(2.W)
  val RS1_WB  = 3.U(2.W)

  // rs2 source select
  val RS2_WI = 2
  val RS2_DEC = 0.U(2.W)
  val RS2_EXE = 1.U(2.W)
  val RS2_MEM = 2.U(2.W)
  val RS2_WB  = 3.U(2.W)

  // ************************************************************
  // Constants

  // thread scheduling slots
  val SLOT_WI = 4
  val SLOT_T0 = 0.U(4.W)
  val SLOT_T1 = 1.U(4.W)
  val SLOT_T2 = 2.U(4.W)
  val SLOT_T3 = 3.U(4.W)
  val SLOT_T4 = 4.U(4.W)
  val SLOT_T5 = 5.U(4.W)
  val SLOT_T6 = 6.U(4.W)
  val SLOT_T7 = 7.U(4.W)
  val SLOT_S  = 14.U(4.W)
  val SLOT_D  = 15.U(4.W)

  // thread modes
  val TMODE_WI = 2
  val TMODE_HA = 0.U(2.W)
  val TMODE_HZ = 1.U(2.W)
  val TMODE_SA = 2.U(2.W)
  val TMODE_SZ = 3.U(2.W)
  val TMODE_AND_A = 2.U(2.W)
  val TMODE_OR_Z  = 1.U(2.W)

  // timer modes
  val TIMER_WI  = 3
  val TIMER_OFF = 0.U(3.W)
  val TIMER_DU  = 1.U(3.W)
  val TIMER_WU  = 2.U(3.W)
  val TIMER_IE  = 3.U(3.W)
  val TIMER_EE  = 4.U(3.W)

  // memory space
  val ADDR_PC_INIT   = "h00000000".U(32.W)
  val ADDR_EVEC_INIT = "h00000000".U(32.W)
  val ADDR_ISPM_BITS = 3
  val ADDR_ISPM_VAL  = "b000".U(ADDR_ISPM_BITS.W)
  val ADDR_DSPM_BITS = 3
  val ADDR_DSPM_VAL  = "b001".U(ADDR_DSPM_BITS.W)
  val ADDR_BUS_BITS  = 2
  val ADDR_BUS_VAL   = "b01".U(ADDR_BUS_BITS.W)

  // memory protection
  val MEMP_WI = 4
  val MEMP_T0 = 0.U(4.W)
  val MEMP_T1 = 1.U(4.W)
  val MEMP_T2 = 2.U(4.W)
  val MEMP_T3 = 3.U(4.W)
  val MEMP_T4 = 4.U(4.W)
  val MEMP_T5 = 5.U(4.W)
  val MEMP_T6 = 6.U(4.W)
  val MEMP_T7 = 7.U(4.W)
  val MEMP_SH = 8.U(4.W) // shared
  val MEMP_RO = 12.U(4.W) // read-only

  // exceptions
  val CAUSE_WI = 5


  // BusIO addresses
  val MMIO_READ_ADDR = 0.U(5.W)
  val MMIO_WRITE_ADDR = 4.U(5.W)
  val MMIO_WRITE_DATA = 8.U(5.W)
  val MMIO_READ_DATA = 12.U(5.W)
  val MMIO_STATUS = 16.U(5.W)


}
