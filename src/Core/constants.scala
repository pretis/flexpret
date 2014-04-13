/******************************************************************************
constants.scala:
  Constant values for parameters, control signals, and RISC-V ISA.
Authors: 
  Michael Zimmer (mzimmer@eecs.berkeley.edu)
  Chris Shaver (shaver@eecs.berkeley.edu)
Acknowledgement:
  Based on Sodor single-thread 5-stage RISC-V processor by Christopher Celio.
  https://github.com/ucb-bar/riscv-sodor/
******************************************************************************/

package Core
{

import Chisel._
import Node._
   
object CoreConstants
{

  //************************************
  // Machine Parameters
  val XPRLEN = 32                // native width of machine (only 32 supported)
  // (i.e., the width of a register in 
  // the general-purpose register file)


  //************************************
  // Control Signals 

  // PC Select Signal
  val PC_PLUS4  = UInt(0, 2);  // PC + 4
  val PC_BRJMP  = UInt(1, 2);  // Branch target address
  val PC_JALR   = UInt(2, 2);  // Jump target address
  val PC_DU     = UInt(3, 2);  // Jump target address 

  // Branch Type
  val BR_N     = UInt(0, 4);  // Next
  val BR_NE    = UInt(1, 4);  // Branch on Not Equal
  val BR_EQ    = UInt(2, 4);  // Branch on Equal
  val BR_GE    = UInt(3, 4);  // Branch on Greater/Equal
  val BR_GEU   = UInt(4, 4);  // Branch on Greater/Equal Unsigned
  val BR_LT    = UInt(5, 4);  // Branch on Less Than
  val BR_LTU   = UInt(6, 4);  // Branch on Less Than Unsigned
  val BR_J     = UInt(7, 4);  // Jump 
  val BR_JR    = UInt(8, 4);  // Jump Register
  val BR_DU    = UInt(9, 4);  // Jump Register 

  // RS2 Operand Select Signal
  val OP2_RS2   = UInt(0, 3); // Register Source #2
  val OP2_BTYPE = UInt(1, 3); // immediate, B-type
  val OP2_ITYPE = UInt(2, 3); // immediate, I-type
  val OP2_LTYPE = UInt(3, 3); // immediate, L-type
  val OP2_JTYPE = UInt(4, 3); // immediate, J-type
  val OP2_X     = UInt(0, 3);

  // Register Operand Output Enable Signal
  val OEN_0   = Bool(false);
  val OEN_1   = Bool(true);

  // Register File Write Enable Signal
  val REN_0   = Bool(false);
  val REN_1   = Bool(true);

  // ALU Operation Signal
  val ALU_ADD    = UInt ( 0, 4);
  val ALU_SUB    = UInt ( 1, 4);
  val ALU_SLL    = UInt ( 2, 4);
  val ALU_SRL    = UInt ( 3, 4);
  val ALU_SRA    = UInt ( 4, 4);
  val ALU_AND    = UInt ( 5, 4);
  val ALU_OR     = UInt ( 6, 4);
  val ALU_XOR    = UInt ( 7, 4);
  val ALU_SLT    = UInt ( 8, 4);
  val ALU_SLTU   = UInt ( 9, 4);
  val ALU_COPY_2 = UInt (10, 4);
  val ALU_MUL    = UInt (11, 4);
  val ALU_MULH   = UInt (12, 4);
  val ALU_MULHSU = UInt (13, 4);
  val ALU_MULHU  = UInt (14, 4);
  val ALU_X      = UInt ( 0, 4);

  // Writeback Address Select Signal
  val WA_RD   = Bool(true)   // write to register rd
  val WA_RA   = Bool(false)  // write to RA register (return address)
  val WA_X    = Bool(true)

  // Writeback Select Signal
  val WB_ALU  = UInt(0, 3);
  val WB_MEM  = UInt(1, 3);
  val WB_PC4  = UInt(2, 3);
  val WB_PCR  = UInt(3, 3);
  val WB_MUL  = UInt(4, 3);
  val WB_GTL  = UInt(5, 3); 
  val WB_GTH  = UInt(6, 3); 
  val WB_X    = UInt(0, 3);

  // Memory Write Signal
  val MWR_0   = Bool(false);
  val MWR_1   = Bool(true);
  val MWR_X   = Bool(false);

  // Memory Enable Signal
  val MEN_0   = Bool(false);
  val MEN_1   = Bool(true);
  val MEN_X   = Bool(false);

  // Memory Mask Type Signal
  val MSK_B   = UInt(0, 3)
  val MSK_BU  = UInt(1, 3)
  val MSK_H   = UInt(2, 3)
  val MSK_HU  = UInt(3, 3)
  val MSK_W   = UInt(4, 3)
  val MSK_X   = UInt(4, 3)

  // Enable Co-processor Register Signal (ToHost Register, etc.)
  val PCR_N   = UInt(0,2)
  val PCR_F   = UInt(1,2)
  val PCR_T   = UInt(2,2)

  // Next PC Fetch Signal
  val NPC_PCREG = UInt(0,3)
  val NPC_BRJMP = UInt(1,3)
  val NPC_PLUS4 = UInt(2,3)
  val NPC_EVEC  = UInt(3,3)
  val NPC_DEC   = UInt(4,3)

  // Exception PC Source Signal 
  val EPC_PCREG = UInt(0,2)
  val EPC_IFPC = UInt(1,2)
  val EPC_DECPC = UInt(2,2)
  val EPC_BRJMP = UInt(3,2)

  // The Bubble Instruction (Machine generated NOP)
  // Insert (XOR x0,x0,x0) which is different from software compiler 
  // generated NOPs which are (ADDI x0, x0, 0).
  // Reasoning for this is to let visualizers and stat-trackers differentiate
  // between software NOPs and machine-generated Bubbles in the pipeline.
  val BUBBLE  = Bits(0x233, 32)

  //************************************
  // RISC-V
  // TODO: clean
  val RA = UInt(1, 5);
  val X = Bits("b?", 1)
  val N = UInt(0, 1);
  val Y = UInt(1, 1);

  val PCR_STATUS   = UInt( 0, 5);
  val PCR_EPC      = UInt( 1, 5); 
  //val PCR_BADVADDR = UInt( 2, 5);
  val PCR_EVEC     = UInt( 3, 5); 
  //val PCR_COUNT    = UInt( 4, 5);
  //val PCR_COMPARE  = UInt( 5, 5);
  //val PCR_CAUSE    = UInt( 6, 5);
  //val PCR_PTBR     = UInt( 7, 5);
  //val PCR_SEND_IPI = UInt( 8, 5);
  //val PCR_CLR_IPI  = UInt( 9, 5);
  //val PCR_COREID   = UInt(10, 5);
  //val PCR_IMPL     = UInt(11, 5);
  //val PCR_K0       = UInt(12, 5);
  //val PCR_K1       = UInt(13, 5);
  //val PCR_VECBANK  = UInt(18, 5);
  //val PCR_VECCFG   = UInt(19, 5);
  val PCR_SHARED   = UInt(18, 5);
  val PCR_PRIV_L   = UInt(19, 5);
  val PCR_PRIV_H   = UInt(20, 5);
  val PCR_TSLEEP   = UInt(21, 5); //todo: best way?
  val PCR_SCHEDULE = UInt(22, 5);
  val PCR_TMODES   = UInt(23, 5);
   val PCR_TSUP    = UInt(24, 5);
  val PCR_INSTS    = UInt(25, 5);
  val PCR_CYCLES   = UInt(26, 5);
  val PCR_TID      = UInt(27, 5);
  //val PCR_RESET    = UInt(29, 5);
  val PCR_TOHOST   = UInt(30, 5);
  //val PCR_FROMHOST = UInt(31, 5);
  //val PCR_STATS    = UInt(10, 5);
  
  // definition of bits in PCR status reg
  val SR_ET   = 0;  // enable traps
  val SR_EF   = 1;  // enable floating point
  val SR_EV   = 2;  // enable vector unit
  val SR_EC   = 3;  // enable compressed instruction encoding
  val SR_PS   = 4;  // mode stack bit
  val SR_S    = 5;  // user/supervisor mode
  val SR_U64  = 6;  // 64 bit user mode
  val SR_S64  = 7;  // 64 bit supervisor mode
  val SR_VM   = 8   // VM enable
  val SR_IM   = 16  // interrupt mask
  val SR_IM_WIDTH = 8
  val SR_THREADS = 28 // Max number of threads
  val SR_THREADS_WIDTH = 3
  val SR_FLEXPRET = 31 // flexpret

  val HRTT = UInt(0,1);
  val SRTT = UInt(1,1);

  val SCH_SRTT = UInt(14,4)
  val SCH_D    = UInt(15,4)

  val TMODE_HA = UInt(0,2);
  val TMODE_HZ = UInt(1,2);
  val TMODE_SA = UInt(2,2);
  val TMODE_SZ = UInt(3,2);
  val TMODE_D  = UInt(0,2);

  // Address space masks.
  val PC_INIT = Bits("h02000000", 32)
  val EVEC_INIT = Bits("h02000000", 32)
  val ADDR_ISPM_BITS = 7
  val ADDR_ISPM_VAL = Bits("b0000_001", ADDR_ISPM_BITS)
  val ADDR_DSPM_BITS = 7
  val ADDR_DSPM_VAL = Bits("b0000_010", ADDR_DSPM_BITS)

  val ADDR_DEST_NONE = UInt(0, 2)
  val ADDR_DEST_DSPM = UInt(1, 2)
  val ADDR_DEST_ISPM = UInt(2, 2)
  val ADDR_DEST_PERIF = UInt(3, 2)



}

}

