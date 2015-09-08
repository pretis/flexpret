/******************************************************************************
File: control.scala
Description: Control unit for decoding instructions and providing signals to
datapath.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._
import Instructions._

class ControlDatapathIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  // outputs to datapath (control independent)
  val dec_imm_sel     = UInt(OUTPUT, IMM_WI)
  val dec_op1_sel     = UInt(OUTPUT, OP1_WI)
  val dec_op2_sel     = UInt(OUTPUT, OP2_WI)
  val exe_alu_type    = UInt(OUTPUT, ALU_WI)
  val exe_br_type     = UInt(OUTPUT, BR_WI)
  val exe_csr_type    = UInt(OUTPUT, CSR_WI)
  val exe_mul_type    = UInt(OUTPUT, MUL_WI)
  val exe_rd_data_sel = UInt(OUTPUT, EXE_RD_WI)
  val exe_mem_type    = UInt(OUTPUT, MEM_WI)
  val mem_rd_data_sel = UInt(OUTPUT, MEM_RD_WI)
  
  // outputs to datapath (control dependent)
  val next_pc_sel     = Vec.fill(conf.threads) { UInt(OUTPUT, NPC_WI) }
  val next_tid        = UInt(OUTPUT, conf.threadBits)
  val next_valid      = Bool(OUTPUT)
  val dec_rs1_sel     = UInt(OUTPUT, RS1_WI)
  val dec_rs2_sel     = UInt(OUTPUT, RS2_WI)
  val exe_valid       = Bool(OUTPUT)
  val exe_load        = Bool(OUTPUT)
  val exe_store       = Bool(OUTPUT)
  val exe_csr_write   = Bool(OUTPUT)
  val exe_exception   = Bool(OUTPUT) // exception occurred
  val exe_cause       = UInt(OUTPUT, CAUSE_WI)
  val exe_kill        = Bool(OUTPUT) // kill stage for unknown instruction
  val exe_sleep       = Bool(OUTPUT) // DU, WU
  val exe_ie          = Bool(OUTPUT) // IE
  val exe_ee          = Bool(OUTPUT) // EE
  val exe_sret        = Bool(OUTPUT)
  val exe_cycle       = Bool(OUTPUT) // stats
  val exe_instret     = Bool(OUTPUT) // stats
  val mem_rd_write    = Bool(OUTPUT)

  // inputs from datapath
  val if_tid      = UInt(INPUT, conf.threadBits)
  val dec_tid     = UInt(INPUT, conf.threadBits)
  val dec_inst    = Bits(INPUT, 32)
  val exe_br_cond = Bool(INPUT)
  val exe_tid     = UInt(INPUT, conf.threadBits)
  val exe_rd_addr = UInt(INPUT, REG_ADDR_BITS)
  val exe_expire  = Bool(INPUT) // DU, WU
  val csr_slots   = Vec.fill(8) { UInt(INPUT, SLOT_WI) }
  val csr_tmodes  = Vec.fill(conf.threads) { UInt(INPUT, TMODE_WI) }
  val mem_tid     = UInt(INPUT, conf.threadBits)
  val mem_rd_addr = UInt(INPUT, REG_ADDR_BITS)
  val wb_tid      = UInt(INPUT, conf.threadBits)
  val wb_rd_addr  = UInt(INPUT, REG_ADDR_BITS)

  // exceptions/interrupts
  val if_exc_misaligned        = Bool(INPUT)
  val if_exc_fault             = Bool(INPUT)
  val exe_exc_priv_inst        = Bool(INPUT)
  val exe_exc_load_misaligned  = Bool(INPUT)
  val exe_exc_load_fault       = Bool(INPUT)
  val exe_exc_store_misaligned = Bool(INPUT)
  val exe_exc_store_fault      = Bool(INPUT)
  val exe_exc_expire           = Bool(INPUT)
  val exe_int_expire           = Bool(INPUT)
  val exe_int_ext              = Bool(INPUT)
}

class Control(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new ControlDatapathIO()
 
  // ************************************************************
  // Decode instruction

  //               legal                                                           exe_rd_data_sel                              load                                  
  //               |  imm_sel                                                      |           mem_type                         |  store                
  //               |  |      op1_sel                                               |           |        mem_rd_data_sel         |  |  fence                    
  //               |  |      |        op1_sel                                      |           |        |           rd_en       |  |  |  fence_i        
  //               |  |      |        |        alu_type                            |           |        |           |  branch   |  |  |  |  scall       
  //               |  |      |        |        |         br_type                   |           |        |           |  |  jump  |  |  |  |  |  sret            
  //               |  |      |        |        |         |       csr_type          |           |        |           |  |  |  csr|  |  |  |  |  |  du ie         
  //               |  |      |        |        |         |       |        mul_type |           |        |           |  |  |  |  |  |  |  |  |  |  |  |   
  val default =                                                                                                                
              List(F, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, F, F, F, F, F, F, F, F, F, F, F)   
  val decode_table = Array(             
    LUI    -> List(T, IMM_U, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    AUIPC  -> List(T, IMM_U, OP1_PC,  OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    JAL    -> List(T, IMM_J, OP1_PC,  OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_PC4, MEM_X,   MEM_RD_REG, T, F, T, F, F, F, F, F, F, F, F, F),  
    JALR   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_PC4, MEM_X,   MEM_RD_REG, T, F, T, F, F, F, F, F, F, F, F, F),  
    BEQ    -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_EQ,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    BNE    -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_NE,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    BLT    -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_LT,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    BGE    -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_GE,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    BLTU   -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_LTU, CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    BGEU   -> List(T, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_GEU, CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , F, T, F, F, F, F, F, F, F, F, F, F),  
    LB     -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LB,  MEM_RD_MEM, T, F, F, F, T, F, F, F, F, F, F, F),  
    LH     -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LH,  MEM_RD_MEM, T, F, F, F, T, F, F, F, F, F, F, F),  
    LW     -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LW,  MEM_RD_MEM, T, F, F, F, T, F, F, F, F, F, F, F),  
    LBU    -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LBU, MEM_RD_MEM, T, F, F, F, T, F, F, F, F, F, F, F),  
    LHU    -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LHU, MEM_RD_MEM, T, F, F, F, T, F, F, F, F, F, F, F),  
    SB     -> List(T, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SB,  MEM_RD_X  , F, F, F, F, F, T, F, F, F, F, F, F),  
    SH     -> List(T, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SH,  MEM_RD_X  , F, F, F, F, F, T, F, F, F, F, F, F),  
    SW     -> List(T, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SW,  MEM_RD_X  , F, F, F, F, F, T, F, F, F, F, F, F),  
    ADDI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLTI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_SLT,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLTIU  -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_SLTU, BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    XORI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_XOR,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    ORI    -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_OR,   BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    ANDI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_AND,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLLI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_SLL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SRLI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_SRL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SRAI   -> List(T, IMM_I, OP1_RS1, OP2_IMM, ALU_SRA,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    ADD    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SUB    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SUB,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLL    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SLL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLT    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SLT,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SLTU   -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SLTU, BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    XOR    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_XOR,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SRL    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SRL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    SRA    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_SRA,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    OR     -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_OR,   BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    AND    -> List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_AND,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, T, F, F, F, F, F, F, F, F, F, F, F),  
    CSRRW  -> List(T, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_W,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    CSRRS  -> List(T, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_S,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    CSRRC  -> List(T, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_C,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    CSRRWI -> List(T, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_W,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    CSRRSI -> List(T, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_S,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    CSRRCI -> List(T, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_C,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, T, F, F, T, F, F, F, F, F, F, F, F),  
    FENCE  -> List(T, IMM_X, OP1_X,   OP2_X,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, T, F, F, F, F, F),  
    FENCE_I-> List(T, IMM_X, OP1_X,   OP2_X,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, T, F, F, F, F),  
    MUL    -> (if(conf.mul) {
              List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_L,   EXE_RD_X,   MEM_X,   MEM_RD_MUL, T, F, F, F, F, F, F, F, F, F, F, F)
              } else { default }),
    MULH   -> (if(conf.mul) {
              List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_H,   EXE_RD_X,   MEM_X,   MEM_RD_MUL, T, F, F, F, F, F, F, F, F, F, F, F)
              } else { default }),
    MULHSU -> (if(conf.mul) {
              List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_HSU, EXE_RD_X,   MEM_X,   MEM_RD_MUL, T, F, F, F, F, F, F, F, F, F, F, F)
              } else { default }),
    MULHU  -> (if(conf.mul) {
              List(T, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_HU,  EXE_RD_X,   MEM_X,   MEM_RD_MUL, T, F, F, F, F, F, F, F, F, F, F, F)
              } else { default }),
    SCALL  -> List(T, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, F, T, F, F, F),
    SRET   -> (if(conf.privilegedMode) {
              List(T, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, F, F, T, F, F)
              } else { default }),
    DU     -> (if(conf.delayUntil) {
              List(T, IMM_X, OP1_PC,  OP2_0,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, F, F, F, T, F)
              } else { default }),
    WU     -> (if(conf.delayUntil) {
              List(T, IMM_X, OP1_PC,  OP2_4,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, F, F, F, T, F) 
              } else { default }),
    IE     -> (if(conf.interruptExpire) {
              List(T, IMM_X, OP1_PC,  OP2_4,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   F, F, F, F, F, F, F, F, F, F, F, T) 
              } else { default })
  )

  //val decoded_inst = ListLookup(io.dec_inst, default, decode_table)
  val decoded_inst = DecodeLogic(io.dec_inst, default, decode_table)

  // decoded information

  val dec_legal :: dec_imm_sel :: dec_op1_sel :: dec_op2_sel :: dec_alu_type :: dec_br_type :: dec_csr_type :: dec_mul_type :: dec_exe_rd_data_sel :: dec_mem_type :: dec_mem_rd_data_sel :: Nil = decoded_inst.slice(0,11)
  val dec_rd_en :: dec_branch :: dec_jump :: dec_csr :: dec_load :: dec_store :: dec_fence :: dec_fence_i :: dec_scall :: dec_sret :: dec_du :: dec_ie :: Nil = decoded_inst.slice(11,23)
  
  // ************************************************************
  // Decoded control signals for datapath operation of stages after decode, 
  // independent of control flow (i.e. even if instruction killed)
  val exe_reg_alu_type    = Reg(next = dec_alu_type)
  val exe_reg_br_type     = Reg(next = dec_br_type)
  val exe_reg_csr_type    = Reg(next = dec_csr_type)
  val exe_reg_mul_type    = Reg(next = dec_mul_type)
  val exe_reg_rd_data_sel = Reg(next = dec_exe_rd_data_sel)
  val exe_reg_mem_type    = Reg(next = dec_mem_type)
  val mem_reg_rd_data_sel = Reg(next = Reg(next = dec_mem_rd_data_sel))

  io.dec_imm_sel     := dec_imm_sel
  io.dec_op1_sel     := dec_op1_sel
  io.dec_op2_sel     := dec_op2_sel
  io.exe_alu_type    := exe_reg_alu_type
  io.exe_br_type     := exe_reg_br_type
  io.exe_csr_type    := exe_reg_csr_type
  io.exe_mul_type    := exe_reg_mul_type
  io.exe_rd_data_sel := exe_reg_rd_data_sel
  io.exe_mem_type    := exe_reg_mem_type
  io.mem_rd_data_sel := mem_reg_rd_data_sel


  // ************************************************************
  // Set to modify control flow (only ever set Bool(true)!)
  // Note: only affects same hardware thread
  
  // Exception from execute stage (kill fetch, decode, execute)
  // Next valid instruction will be from evec address
  val exe_exception = Bool()
  exe_exception := Bool(false) // default value
  val mem_reg_exception = Reg(next = exe_exception)

  // Flush pipeline from execute stage (kill fetch, decode)
  val exe_flush = Bool()
  exe_flush := exe_exception // default value

  // Stall fetch from decode stage (kill fetch)
  val dec_stall = Bool()
  dec_stall := Bool(false) // default value
  
  // Multicycle stall (kill fetch multiple times)
  val stall_count = Vec.fill(conf.threads) { Reg(init = UInt(0, 2)) }
  for(tid <- 0 until conf.threads) {
    // default behavior is decrement
    stall_count(tid) := Mux(stall_count(tid) != UInt(0), stall_count(tid) - UInt(1), UInt(0))
  }

  // 1 cycle instruction: -
  // 2 cycle instruction: dec_stall = true
  // 3 cycle instruction: dec_stall = true; stall_count(tid) = 1
  // 4 cycle instruction: dec_stall = true; stall_count(tid) = 2
  // ...
  
  // ************************************************************
  // Current status of each stage (valid if previous stage was valid and no
  // stall/flush operation).
  // Avoid using if_valid, dec_valid, and exe_valid in control logic because
  // of dependency on exe_flush from exceptions (long path)
  val next_valid    = Bool()
  val if_reg_valid  = Reg(next = next_valid, init = Bool(false))
  val if_pre_valid  = if_reg_valid &&
                      !(dec_stall && (io.if_tid === io.dec_tid)) &&
                      stall_count(io.if_tid) === UInt(0)
  val if_valid      = if_pre_valid &&
                      !(exe_flush && (io.if_tid === io.exe_tid))
  val dec_reg_valid = Reg(next = if_valid,   init = Bool(false))
  val dec_valid     = dec_reg_valid &&
                      !(exe_flush && (io.dec_tid === io.exe_tid))
  val exe_reg_valid = Reg(next = dec_valid,  init = Bool(false))
  val exe_valid     = exe_reg_valid && !exe_exception
  debug(exe_valid)
  val mem_reg_valid = Reg(next = exe_valid,  init = Bool(false))
  val mem_valid     = mem_reg_valid
  val wb_reg_valid  = Reg(next = mem_valid,  init = Bool(false))
  val wb_valid      = wb_reg_valid

  // ************************************************************
  // Control signals that depend on control flow

  // Thread scheduling uses current state and control registers (slots and
  // tmodes).
  val next_tid = UInt()
  val scheduler = Module(new Scheduler())
  scheduler.io.slots := io.csr_slots
  scheduler.io.thread_modes := io.csr_tmodes
  if(!conf.regSchedule) {
    next_tid := scheduler.io.thread
    next_valid := scheduler.io.valid
  } else {
    next_tid := Reg(next = scheduler.io.thread)
    next_valid := Reg(next = scheduler.io.valid, init = Bool(false))
  }

  // Keep track of address and decision to write to rd, used for forwarding
  // logic and writeback stage.
  val dec_rd_write = (io.dec_inst(11, 7) != UInt(0)) && dec_rd_en.toBool
  // dec_reg_valid != dec_valid requires flush, next instruction in decode will
  // not be valid if from same thread, so forwarding decision doesn't matter
  val exe_reg_rd_write = Reg(next = dec_rd_write && dec_reg_valid) 
  // exe_reg_valid != exe_valid requires exeception->flush, next instruction in
  // decode will not be valid if from same thread, so forwarding decision
  // doesn't matter
  val mem_reg_rd_write = Reg(next = exe_reg_rd_write && exe_reg_valid)
  val mem_rd_write = mem_reg_rd_write && mem_reg_valid
  // More conservative wrt valid
  //val exe_reg_rd_write = Reg(next = dec_rd_write && dec_valid)
  //val mem_reg_rd_write = Reg(next = exe_reg_rd_write && exe_valid)
  //val mem_rd_write = mem_reg_rd_write
  val wb_reg_rd_write  = Reg(next = mem_rd_write)
  
  // Keep track of write to CSR
  // Write can be true even when exception occurs (prevent feedback logic with
  // CSR exceptions)
  val exe_reg_csr_write = Reg(next = dec_csr.toBool)
  val exe_csr_write = exe_reg_csr_write && exe_reg_valid

  // Keep track of system instructions
  val exe_reg_scall = Reg(next = dec_scall.toBool)
  val exe_reg_sret = Reg(next = dec_sret.toBool)
  val exe_sret = exe_reg_sret && exe_reg_valid

  // Keep track of load/store.
  // Load/store can be true even when exception occurs (prevent feedback logic
  // with load/store exceptions)
  val exe_reg_load = Reg(next = dec_load.toBool)
  val exe_load = exe_reg_load && exe_reg_valid
  val exe_reg_store = Reg(next = dec_store.toBool)
  val exe_store = exe_reg_store && exe_reg_valid
  
  // Keep track of branch/jump instruction.
  val exe_reg_branch = Reg(next = dec_branch.toBool)
  val exe_reg_jump = Reg(next = dec_jump.toBool)
  // Assumes exception has higher PC priority than branch/jump
  val exe_brjmp = exe_reg_valid && (exe_reg_jump || (exe_reg_branch && io.exe_br_cond))
  // More conservative wrt valid
  //val exe_brjmp = exe_valid && (exe_reg_jump || (exe_reg_branch && io.exe_br_cond))

  // Keep track of delay_until instruction.
  val exe_du = Bool()
  if(conf.delayUntil) {
    val exe_reg_du = Reg(next = dec_du.toBool)
    // If instruction is valid and compare time value has not expired, set PC:
    // DU: address of DU (branch to self)
    // WU: adress of WU+4 (branch to next instruction)
    // Assumes exception has higher PC priority than DU/WU
    exe_du := exe_reg_valid && exe_reg_du && !io.exe_expire
    // Otherwise just keep executing.
  } else {
    exe_du := Bool(false)
  }
  // If DU or WU, put thread to sleep and set timer to wake on expiration
  val exe_sleep = exe_du && exe_valid
 
  // If PC coming from ALU
 //val mem_reg_brjmp = Reg(next = exe_brjmp || exe_du)
  val mem_reg_brjmp = Reg(next = (exe_brjmp || exe_du) && exe_valid)
  
  // Keep track of interrupt/exception on expire instruction.
  val exe_ie = Bool()
  val exe_ee = Bool()
  if(conf.interruptExpire) {
  val exe_reg_ie = Reg(next = dec_ie.toBool && io.dec_inst(25).toBool)
  exe_ie := exe_valid && exe_reg_ie
  val exe_reg_ee = Reg(next = dec_ie.toBool && !io.dec_inst(25).toBool)
  exe_ee := exe_valid && exe_reg_ee
  } else {
    exe_ie := Bool(false)
    exe_ee := Bool(false)
  }
  
  // Forwarding logic for rs1 and rs2
  val dec_rs1_sel = UInt()
  val dec_rs2_sel = UInt()
  if(conf.bypassing) {
    // Assume rs1/rs2 select doesn't matter if execute stage killed (don't need to wait on exe_valid signal).
    // Also doesn't matter if data forwarded if rs1 or rs2 not used.
    val dec_rs1_addr = io.dec_inst(19, 15)
    val dec_rs2_addr = io.dec_inst(24, 20)
    val dec_check_exe = (io.dec_tid === io.exe_tid) && exe_reg_rd_write
    val dec_check_mem = (io.dec_tid === io.mem_tid) && mem_reg_rd_write
    val dec_check_wb  = (io.dec_tid === io.wb_tid)  && wb_reg_rd_write
    dec_rs1_sel :=
      Mux(dec_check_exe && (dec_rs1_addr === io.exe_rd_addr), RS1_EXE,
      Mux(dec_check_mem && (dec_rs1_addr === io.mem_rd_addr), RS1_MEM,
      Mux(dec_check_wb  && (dec_rs1_addr === io.wb_rd_addr),  RS1_WB,
      RS1_DEC)))
    dec_rs2_sel :=
      Mux(dec_check_exe && (dec_rs2_addr === io.exe_rd_addr), RS2_EXE,
      Mux(dec_check_mem && (dec_rs2_addr === io.mem_rd_addr), RS2_MEM,
      Mux(dec_check_wb  && (dec_rs2_addr === io.wb_rd_addr),  RS2_WB,
      RS2_DEC)))
  } else {
    dec_rs1_sel := RS1_DEC
    dec_rs2_sel := RS2_DEC
  }

  // Determine how to update PC for each thread. 
  val next_pc_sel = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) { next_pc_sel := NPC_PCREG }
  when(if_pre_valid)            { next_pc_sel(io.if_tid)  := NPC_PLUS4 }
  if(!conf.regBrJmp) {
    when(exe_brjmp || exe_du)   { next_pc_sel(io.exe_tid) := NPC_BRJMP }
    } else {
    when(mem_reg_brjmp)         { next_pc_sel(io.mem_tid) := NPC_BRJMP }
  }
  if(conf.exceptions) {
    if(!conf.regEvec) {
      when(exe_exception)       { next_pc_sel(io.exe_tid) := NPC_EVEC  }
    } else {
      when(mem_reg_exception)   { next_pc_sel(io.mem_tid) := NPC_EVEC  }
    }
  }

  // ************************************************************
  // Exception, flush, and stall logic
  
  // If branch taken, kill any instructions from same thread in pipeline
  when(exe_brjmp) {
    exe_flush := Bool(true)
    if(conf.regBrJmp) { stall_count(io.exe_tid) := UInt(1) }
  }

  // If thread going to sleep, kill any instructions from same thread until
  // no longer scheduled
  when(exe_sleep) {
    exe_flush := Bool(true)
    if(!conf.regSchedule) {
      stall_count(io.exe_tid) := UInt(1) // takes cycle for sleep to affect schedule
    } else {
      stall_count(io.exe_tid) := UInt(2) // takes 2 cycles for sleep to affect schedule
    }
  }

  // Make all load instructions take 2 cycles
  // Simplier than detecting load-use and only affect single-threaded mode
  when(dec_reg_valid && dec_load.toBool) {
    dec_stall := Bool(true)
  }

  // Make all multiplication instructions take 2 cycles
  if(conf.mul) {
    when(dec_reg_valid && (dec_mem_rd_data_sel === MEM_RD_MUL)) {
      dec_stall := Bool(true)
    }
  }

  // A simple implementation of the FENCE.I instruction is to prevent the
  // thread from fetching or executing another instruction until the 
  // FENCE.I instruction has completed execute stage (so any preceding 
  // instruction has completed at least memory stage). This can be done by
  // killing any instruction with the same thread ID in fetch for 2 cycles.
  when(dec_reg_valid && dec_fence_i.toBool) {
    dec_stall := Bool(true)
    stall_count(io.exe_tid) := UInt(1)
  }

  // Not anymore...
  // If CSRs.compare set, comparison not valid in next cycle yet
  //when(dec_reg_valid && dec_csr.toBool && (io.dec_inst(31, 20) === UInt(CSRs.compare))) {
  //  dec_stall := Bool(true)
  //}

  // For each stage, keep track of high priority exception.
  // Ignored if instruction is not valid at execute stage.
  
  // Highest priority first
  def check_exceptions(exceptions: Seq[(Bool, Int)]) = {
    val enabled = exceptions.filter(i => conf.causes.contains(i._2))
    val exception = enabled.map(_._1).fold(Bool(false))(_||_)
    var cause = UInt(0)
    enabled.reverse.foreach { i => cause = Mux(i._1, UInt(i._2), cause) }
    (exception, cause)
     //enabled.foldRight[Data](UInt(0))((r,c) => Mux(c._1, UInt(c._2), r)))
  }

  // Fetch stage exceptions
  val (if_exc, if_cause) = check_exceptions(List(
      (io.if_exc_misaligned, Causes.misaligned_fetch),
      (io.if_exc_fault, Causes.fault_fetch)
    ))

  val dec_reg_exc = Reg(next = if_exc)
  val dec_reg_cause = Reg(next = if_cause)
 
  // Decode stage exceptions
  val (dec_exc, dec_cause) = check_exceptions(List(
      (!dec_legal.toBool, Causes.illegal_instruction),
      (dec_scall.toBool, Causes.syscall)
    ))
  
  val exe_reg_exc = Reg(next = dec_reg_exc || dec_exc)
  val exe_reg_cause = Reg(next = Mux(dec_reg_exc, dec_reg_cause, dec_cause))
 
  // Execute stage exceptions
  // Caused by known instruction in execute stage, let logic that threw 
  // exception also prevent commit
  val (exe_inst_exc, exe_inst_cause) = check_exceptions(List(
      (io.exe_exc_priv_inst, Causes.privileged_instruction),
      (io.exe_exc_load_misaligned, Causes.misaligned_load),
      (io.exe_exc_load_fault, Causes.fault_load),
      (io.exe_exc_store_misaligned, Causes.misaligned_store),
      (io.exe_exc_store_fault, Causes.fault_store)
    ))
  // Caused by unknown instruction in execute stage, prevent all commits
  val (exe_any_exc, exe_any_cause) = check_exceptions(List(
      (io.exe_exc_expire, Causes.ee),
      (io.exe_int_expire, Causes.ie),
      (io.exe_int_ext, Causes.external_int)
    ))

  // Prevent any commit if detected before execute stage or caused by unknown
  // instruction in execute stage. Separate from exe_exception so other commit
  // points don't need to wait for load/store/priv exception detection.
  val exe_kill = exe_reg_exc || exe_any_exc
  
  // Handle all exceptions in execute stage.
  val exe_exception_cause = UInt()
  exe_exception_cause := UInt(0)

  if(conf.exceptions) {
    // must be valid instruction otherwise hard to know what PC to store
    when(exe_reg_valid && (exe_reg_exc || exe_inst_exc || exe_any_exc)) {
      exe_exception := Bool(true)
      if(conf.regEvec) { stall_count(io.exe_tid) := UInt(1) }
      else { stall_count(io.exe_tid) := UInt(0) }
    }
    exe_exception_cause := Mux(exe_reg_exc, exe_reg_cause, 
                           Mux(exe_inst_exc, exe_inst_cause, exe_any_cause))
  }
 
  // Without bypassing, no other instructions from the same thread can be in the
  // pipeline, just override all previous logic
  if(!conf.bypassing) {
    exe_flush := Bool(false)
    dec_stall := Bool(false)
    stall_count := UInt(0) // until any logic needs >= 3
  }

  // stats
  val exe_cycle = Bool()
  exe_cycle := Bool(false) // default value
  val exe_instret = Bool()
  exe_instret := Bool(false) // default value
  if(conf.stats) {
    exe_cycle := Reg(next = Reg(next = Reg(next = next_valid)))
    exe_instret := exe_valid
  }

  // to datapath
  io.next_tid      := next_tid
  io.next_valid    := next_valid
  io.next_pc_sel   := next_pc_sel
  io.dec_rs1_sel   := dec_rs1_sel
  io.dec_rs2_sel   := dec_rs2_sel
  io.exe_valid     := exe_reg_valid
  io.exe_load      := exe_load
  io.exe_store     := exe_store
  io.exe_csr_write := exe_csr_write
  io.exe_exception := exe_exception
  io.exe_cause     := exe_exception_cause
  io.exe_kill      := exe_kill
  io.exe_sleep     := exe_sleep
  io.exe_ie        := exe_ie
  io.exe_ee        := exe_ee
  io.exe_sret      := exe_sret
  io.exe_cycle     := exe_cycle
  io.exe_instret   := exe_instret
  io.mem_rd_write  := mem_rd_write


}

