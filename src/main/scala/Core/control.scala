/******************************************************************************
File: control.scala
Description: Control unit for decoding instructions and providing signals to
datapath.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util.BitPat

// Remove this eventually
import Core.Causes
import Core.DecodeLogic
import Core.Scheduler
import Core.FlexpretConstants._
import Core.Instructions._

import scala.language.implicitConversions
import flexpret.util.uintToBitPatObject._

class ControlDatapathIO(implicit val conf: FlexpretConfiguration) extends Bundle
{
  // outputs to datapath (control independent)
  val dec_imm_sel     = Output(UInt(IMM_WI.W))
  val dec_op1_sel     = Output(UInt(OP1_WI.W))
  val dec_op2_sel     = Output(UInt(OP2_WI.W))
  val exe_alu_type    = Output(UInt(ALU_WI.W))
  val exe_br_type     = Output(UInt(BR_WI.W))
  val exe_csr_type    = Output(UInt(CSR_WI.W))
  val exe_mul_type    = Output(UInt(MUL_WI.W))
  val exe_rd_data_sel = Output(UInt(EXE_RD_WI.W))
  val exe_mem_type    = Output(UInt(MEM_WI.W))
  val mem_rd_data_sel = Output(UInt(MEM_RD_WI.W))

  // outputs to datapath (control dependent)
  val next_pc_sel     = Output(Vec(conf.threads, UInt(NPC_WI.W)))
  val next_tid        = Output(UInt(conf.threadBits.W))
  val next_valid      = Output(Bool())
  val dec_rs1_sel     = Output(UInt(RS1_WI.W))
  val dec_rs2_sel     = Output(UInt(RS2_WI.W))
  val exe_valid       = Output(Bool())
  val exe_load        = Output(Bool())
  val exe_store       = Output(Bool())
  val exe_csr_write   = Output(Bool())
  val exe_exception   = Output(Bool()) // exception occurred
  val exe_cause       = Output(UInt(CAUSE_WI.W))
  val exe_kill        = Output(Bool()) // kill stage for unknown instruction
  val exe_sleep       = Output(Bool()) // DU, WU
  val exe_ie          = Output(Bool()) // IE
  val exe_ee          = Output(Bool()) // EE
  val exe_sret        = Output(Bool())
  val exe_cycle       = Output(Bool()) // stats
  val exe_instret     = Output(Bool()) // stats
  val mem_rd_write    = Output(Bool())

  // inputs from datapath
  val if_tid      = Input(UInt(conf.threadBits.W))
  val dec_tid     = Input(UInt(conf.threadBits.W))
  val dec_inst    = Input(UInt(32.W))
  val exe_br_cond = Input(Bool())
  val exe_tid     = Input(UInt(conf.threadBits.W))
  val exe_rd_addr = Input(UInt(REG_ADDR_BITS.W))
  val exe_expire  = Input(Bool()) // DU, WU
  val csr_slots   = Input(Vec(8, UInt(SLOT_WI.W)))
  val csr_tmodes  = Input(Vec(conf.threads, UInt(TMODE_WI.W)))
  val mem_tid     = Input(UInt(conf.threadBits.W))
  val mem_rd_addr = Input(UInt(REG_ADDR_BITS.W))
  val wb_tid      = Input(UInt(conf.threadBits.W))
  val wb_rd_addr  = Input(UInt(REG_ADDR_BITS.W))

  // exceptions/interrupts
  val if_exc_misaligned        = Input(Bool())
  val if_exc_fault             = Input(Bool())
  val exe_exc_priv_inst        = Input(Bool())
  val exe_exc_load_misaligned  = Input(Bool())
  val exe_exc_load_fault       = Input(Bool())
  val exe_exc_store_misaligned = Input(Bool())
  val exe_exc_store_fault      = Input(Bool())
  val exe_exc_expire           = Input(Bool())
  val exe_int_expire           = Input(Bool())
  val exe_int_ext              = Input(Bool())

  override def cloneType = (new ControlDatapathIO).asInstanceOf[this.type]
}

class Control(implicit val conf: FlexpretConfiguration) extends Module
{
  val io = IO(new ControlDatapathIO())

  // ************************************************************
  // Decode instruction

  //               legal                                                           exe_rd_data_sel                              load
  //               |  imm_sel                                                      |           mem_type                         |  store
  //               |  |      op1_sel                                               |           |        mem_rd_data_sel         |  |  fence
  //               |  |      |        op2_sel                                      |           |        |           rd_en       |  |  |  fence_i
  //               |  |      |        |        alu_type                            |           |        |           |  branch   |  |  |  |  scall
  //               |  |      |        |        |         br_type                   |           |        |           |  |  jump  |  |  |  |  |  sret
  //               |  |      |        |        |         |       csr_type          |           |        |           |  |  |  csr|  |  |  |  |  |  du ie
  //               |  |      |        |        |         |       |        mul_type |           |        |           |  |  |  |  |  |  |  |  |  |  |  |
  val default: List[BitPat] =
              List(N, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, N, N, N, N, N, N, N, N, N, N, N)
  val decode_table: Array[(BitPat, List[BitPat])] = Array(
    LUI    -> List(Y, IMM_U, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    AUIPC  -> List(Y, IMM_U, OP1_PC,  OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    JAL    -> List(Y, IMM_J, OP1_PC,  OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_PC4, MEM_X,   MEM_RD_REG, Y, N, Y, N, N, N, N, N, N, N, N, N),
    JALR   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_PC4, MEM_X,   MEM_RD_REG, Y, N, Y, N, N, N, N, N, N, N, N, N),
    BEQ    -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_EQ,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    BNE    -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_NE,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    BLT    -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_LT,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    BGE    -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_GE,  CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    BLTU   -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_LTU, CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    BGEU   -> List(Y, IMM_B, OP1_PC,  OP2_IMM, ALU_ADD,  BR_GEU, CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X  , N, Y, N, N, N, N, N, N, N, N, N, N),
    LB     -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LB,  MEM_RD_MEM, Y, N, N, N, Y, N, N, N, N, N, N, N),
    LH     -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LH,  MEM_RD_MEM, Y, N, N, N, Y, N, N, N, N, N, N, N),
    LW     -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LW,  MEM_RD_MEM, Y, N, N, N, Y, N, N, N, N, N, N, N),
    LBU    -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LBU, MEM_RD_MEM, Y, N, N, N, Y, N, N, N, N, N, N, N),
    LHU    -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_LHU, MEM_RD_MEM, Y, N, N, N, Y, N, N, N, N, N, N, N),
    SB     -> List(Y, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SB,  MEM_RD_X  , N, N, N, N, N, Y, N, N, N, N, N, N),
    SH     -> List(Y, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SH,  MEM_RD_X  , N, N, N, N, N, Y, N, N, N, N, N, N),
    SW     -> List(Y, IMM_S, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_SW,  MEM_RD_X  , N, N, N, N, N, Y, N, N, N, N, N, N),
    ADDI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLTI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_SLT,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLTIU  -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_SLTU, BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    XORI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_XOR,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    ORI    -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_OR,   BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    ANDI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_AND,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLLI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_SLL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SRLI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_SRL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SRAI   -> List(Y, IMM_I, OP1_RS1, OP2_IMM, ALU_SRA,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    ADD    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SUB    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SUB,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLL    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SLL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLT    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SLT,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SLTU   -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SLTU, BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    XOR    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_XOR,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SRL    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SRL,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    SRA    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_SRA,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    OR     -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_OR,   BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    AND    -> List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_AND,  BR_X,   CSR_X,   MUL_X,   EXE_RD_ALU, MEM_X,   MEM_RD_REG, Y, N, N, N, N, N, N, N, N, N, N, N),
    CSRRW  -> List(Y, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_W,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    CSRRS  -> List(Y, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_S,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    CSRRC  -> List(Y, IMM_X, OP1_RS1, OP2_0,   ALU_ADD,  BR_X,   CSR_C,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    CSRRWI -> List(Y, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_W,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    CSRRSI -> List(Y, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_S,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    CSRRCI -> List(Y, IMM_Z, OP1_0,   OP2_IMM, ALU_ADD,  BR_X,   CSR_C,   MUL_X,   EXE_RD_CSR, MEM_X,   MEM_RD_REG, Y, N, N, Y, N, N, N, N, N, N, N, N),
    FENCE  -> List(Y, IMM_X, OP1_X,   OP2_X,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, Y, N, N, N, N, N),
    FENCE_I-> List(Y, IMM_X, OP1_X,   OP2_X,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, Y, N, N, N, N),
    MUL    -> (if(conf.mul) {
              List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_L,   EXE_RD_X,   MEM_X,   MEM_RD_MUL, Y, N, N, N, N, N, N, N, N, N, N, N)
              } else { default }),
    MULH   -> (if(conf.mul) {
              List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_H,   EXE_RD_X,   MEM_X,   MEM_RD_MUL, Y, N, N, N, N, N, N, N, N, N, N, N)
              } else { default }),
    MULHSU -> (if(conf.mul) {
              List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_HSU, EXE_RD_X,   MEM_X,   MEM_RD_MUL, Y, N, N, N, N, N, N, N, N, N, N, N)
              } else { default }),
    MULHU  -> (if(conf.mul) {
              List(Y, IMM_X, OP1_RS1, OP2_RS2, ALU_X,    BR_X,   CSR_X,   MUL_HU,  EXE_RD_X,   MEM_X,   MEM_RD_MUL, Y, N, N, N, N, N, N, N, N, N, N, N)
              } else { default }),
    SCALL  -> List(Y, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, N, Y, N, N, N),
    SRET   -> (if(conf.privilegedMode) {
              List(Y, IMM_X, OP1_X,   OP2_X,   ALU_X,    BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, N, N, Y, N, N)
              } else { default }),
    DU     -> (if(conf.delayUntil) {
              List(Y, IMM_X, OP1_PC,  OP2_0,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, N, N, N, Y, N)
              } else { default }),
    WU     -> (if(conf.delayUntil) {
              List(Y, IMM_X, OP1_PC,  OP2_4,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, N, N, N, Y, N)
              } else { default }),
    IE     -> (if(conf.interruptExpire) {
              List(Y, IMM_X, OP1_PC,  OP2_4,   ALU_ADD,  BR_X,   CSR_X,   MUL_X,   EXE_RD_X,   MEM_X,   MEM_RD_X,   N, N, N, N, N, N, N, N, N, N, N, Y)
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
  val exe_reg_alu_type    = RegNext(dec_alu_type)
  val exe_reg_br_type     = RegNext(dec_br_type)
  val exe_reg_csr_type    = RegNext(dec_csr_type)
  val exe_reg_mul_type    = RegNext(dec_mul_type)
  val exe_reg_rd_data_sel = RegNext(dec_exe_rd_data_sel)
  val exe_reg_mem_type    = RegNext(dec_mem_type)
  val mem_reg_rd_data_sel = RegNext(RegNext(dec_mem_rd_data_sel))

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
  // Set to modify control flow (only ever set true.B!)
  // Note: only affects same hardware thread

  // Exception from execute stage (kill fetch, decode, execute)
  // Next valid instruction will be from evec address
  val exe_exception = Wire(Bool())
  exe_exception := false.B // default value
  val mem_reg_exception = RegNext(exe_exception)

  // Flush pipeline from execute stage (kill fetch, decode)
  val exe_flush = Wire(Bool())
  exe_flush := exe_exception // default value

  // Stall fetch from decode stage (kill fetch)
  val dec_stall = Wire(Bool())
  dec_stall := false.B // default value

  // Multicycle stall (kill fetch multiple times)
  val stall_count = RegInit(VecInit(Seq.fill(conf.threads){ 0.U(2.W) }))
  for(tid <- 0 until conf.threads) {
    // default behavior is decrement
    stall_count(tid) := Mux(stall_count(tid) =/= 0.U, stall_count(tid) - 1.U, 0.U)
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
  val next_valid    = Wire(Bool())
  val if_reg_valid  = RegNext(next_valid, init = false.B)
  val if_pre_valid  = if_reg_valid &&
                      !(dec_stall && (io.if_tid === io.dec_tid)) &&
                      stall_count(io.if_tid) === 0.U
  val if_valid      = if_pre_valid &&
                      !(exe_flush && (io.if_tid === io.exe_tid))
  val dec_reg_valid = RegNext(if_valid,   init = false.B)
  val dec_valid     = dec_reg_valid &&
                      !(exe_flush && (io.dec_tid === io.exe_tid))
  val exe_reg_valid = RegNext(dec_valid,  init = false.B)
  val exe_valid     = exe_reg_valid && !exe_exception
  val mem_reg_valid = RegNext(exe_valid,  init = false.B)
  val mem_valid     = mem_reg_valid
  val wb_reg_valid  = RegNext(mem_valid,  init = false.B)
  val wb_valid      = wb_reg_valid

  // ************************************************************
  // Control signals that depend on control flow

  // Thread scheduling uses current state and control registers (slots and
  // tmodes).
  val next_tid = Wire(UInt())
  val scheduler = Module(new Scheduler())
  scheduler.io.slots := io.csr_slots
  scheduler.io.thread_modes := io.csr_tmodes
  if(!conf.regSchedule) {
    next_tid := scheduler.io.thread
    next_valid := scheduler.io.valid
  } else {
    next_tid := RegNext(scheduler.io.thread)
    next_valid := RegNext(scheduler.io.valid, init = false.B)
  }

  // Keep track of address and decision to write to rd, used for forwarding
  // logic and writeback stage.
  val dec_rd_write = (io.dec_inst(11, 7) =/= 0.U) && dec_rd_en.asBool
  // dec_reg_valid != dec_valid requires flush, next instruction in decode will
  // not be valid if from same thread, so forwarding decision doesn't matter
  val exe_reg_rd_write = RegNext(dec_rd_write && dec_reg_valid)
  // exe_reg_valid != exe_valid requires exeception->flush, next instruction in
  // decode will not be valid if from same thread, so forwarding decision
  // doesn't matter
  val mem_reg_rd_write = RegNext(exe_reg_rd_write && exe_reg_valid)
  val mem_rd_write = mem_reg_rd_write && mem_reg_valid
  // More conservative wrt valid
  //val exe_reg_rd_write = RegNext(dec_rd_write && dec_valid)
  //val mem_reg_rd_write = RegNext(exe_reg_rd_write && exe_valid)
  //val mem_rd_write = mem_reg_rd_write
  val wb_reg_rd_write  = RegNext(mem_rd_write)

  // Keep track of write to CSR
  // Write can be true even when exception occurs (prevent feedback logic with
  // CSR exceptions)
  val exe_reg_csr_write = RegNext(dec_csr.asBool)
  val exe_csr_write = exe_reg_csr_write && exe_reg_valid

  // Keep track of system instructions
  val exe_reg_scall = RegNext(dec_scall.asBool)
  val exe_reg_sret = RegNext(dec_sret.asBool)
  val exe_sret = exe_reg_sret && exe_reg_valid

  // Keep track of load/store.
  // Load/store can be true even when exception occurs (prevent feedback logic
  // with load/store exceptions)
  val exe_reg_load = RegNext(dec_load.asBool)
  val exe_load = exe_reg_load && exe_reg_valid
  val exe_reg_store = RegNext(dec_store.asBool)
  val exe_store = exe_reg_store && exe_reg_valid

  // Keep track of branch/jump instruction.
  val exe_reg_branch = RegNext(dec_branch.asBool)
  val exe_reg_jump = RegNext(dec_jump.asBool)
  // Assumes exception has higher PC priority than branch/jump
  val exe_brjmp = exe_reg_valid && (exe_reg_jump || (exe_reg_branch && io.exe_br_cond))
  // More conservative wrt valid
  //val exe_brjmp = exe_valid && (exe_reg_jump || (exe_reg_branch && io.exe_br_cond))

  // Keep track of delay_until instruction.
  val exe_du: Bool = if (conf.delayUntil) {
    val exe_reg_du = RegNext(dec_du.asBool)
    // If instruction is valid and compare time value has not expired, set PC:
    // DU: address of DU (branch to self)
    // WU: adress of WU+4 (branch to next instruction)
    // Assumes exception has higher PC priority than DU/WU
    exe_reg_valid && exe_reg_du && !io.exe_expire
    // Otherwise just keep executing.
  } else {
    false.B
  }
  // If DU or WU, put thread to sleep and set timer to wake on expiration
  val exe_sleep = exe_du && exe_valid

  // If PC coming from ALU
 //val mem_reg_brjmp = RegNext(exe_brjmp || exe_du)
  val mem_reg_brjmp = RegNext((exe_brjmp || exe_du) && exe_valid)

  // Keep track of interrupt/exception on expire instruction.
  val exe_ie = Wire(Bool())
  val exe_ee = Wire(Bool())
  if(conf.interruptExpire) {
  val exe_reg_ie = RegNext(dec_ie.asBool && io.dec_inst(25).asBool)
  exe_ie := exe_valid && exe_reg_ie
  val exe_reg_ee = RegNext(dec_ie.asBool && !io.dec_inst(25).asBool)
  exe_ee := exe_valid && exe_reg_ee
  } else {
    exe_ie := false.B
    exe_ee := false.B
  }

  // Forwarding logic for rs1 and rs2
  val dec_rs1_sel = Wire(UInt())
  val dec_rs2_sel = Wire(UInt())
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
  val next_pc_sel = Wire(Vec(conf.threads, UInt(2.W)))
  for(tid <- 0 until conf.threads) { next_pc_sel(tid) := NPC_PCREG }
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
    exe_flush := true.B
    if(conf.regBrJmp) { stall_count(io.exe_tid) := 1.U }
  }

  // If thread going to sleep, kill any instructions from same thread until
  // no longer scheduled
  when(exe_sleep) {
    exe_flush := true.B
    if(!conf.regSchedule) {
      stall_count(io.exe_tid) := 1.U // takes cycle for sleep to affect schedule
    } else {
      stall_count(io.exe_tid) := 2.U // takes 2 cycles for sleep to affect schedule
    }
  }

  // Make all load instructions take 2 cycles
  // Simplier than detecting load-use and only affect single-threaded mode
  when(dec_reg_valid && dec_load.asBool) {
    dec_stall := true.B
  }

  // Make all multiplication instructions take 2 cycles
  if(conf.mul) {
    when(dec_reg_valid && (dec_mem_rd_data_sel === MEM_RD_MUL)) {
      dec_stall := true.B
    }
  }

  // A simple implementation of the FENCE.I instruction is to prevent the
  // thread from fetching or executing another instruction until the
  // FENCE.I instruction has completed execute stage (so any preceding
  // instruction has completed at least memory stage). This can be done by
  // killing any instruction with the same thread ID in fetch for 2 cycles.
  when(dec_reg_valid && dec_fence_i.asBool) {
    dec_stall := true.B
    stall_count(io.exe_tid) := 1.U
  }

  // Not anymore...
  // If CSRs.compare set, comparison not valid in next cycle yet
  //when(dec_reg_valid && dec_csr.asBool && (io.dec_inst(31, 20) === UInt(CSRs.compare))) {
  //  dec_stall := true.B
  //}

  // For each stage, keep track of high priority exception.
  // Ignored if instruction is not valid at execute stage.

  // Highest priority first
  def check_exceptions(exceptions: Seq[(Bool, Int)]) = {
    val enabled = exceptions.filter(i => conf.causes.contains(i._2))
    val exception = enabled.map(_._1).fold(false.B)(_||_)
    var cause = 0.U
    enabled.reverse.foreach { i => cause = Mux(i._1, i._2.U, cause) }
    (exception, cause)
     //enabled.foldRight[Data](0.U)((r,c) => Mux(c._1, c._2.U, r)))
  }

  // Fetch stage exceptions
  val (if_exc, if_cause) = check_exceptions(List(
      (io.if_exc_misaligned, Causes.misaligned_fetch),
      (io.if_exc_fault, Causes.fault_fetch)
    ))

  val dec_reg_exc = RegNext(if_exc)
  val dec_reg_cause = RegNext(if_cause)

  // Decode stage exceptions
  val (dec_exc, dec_cause) = check_exceptions(List(
      (!dec_legal.asBool, Causes.illegal_instruction),
      (dec_scall.asBool, Causes.syscall)
    ))

  val exe_reg_exc = RegNext(dec_reg_exc || dec_exc)
  val exe_reg_cause = RegNext(Mux(dec_reg_exc, dec_reg_cause, dec_cause))

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
  val exe_exception_cause = Wire(UInt())
  exe_exception_cause := 0.U

  if(conf.exceptions) {
    // must be valid instruction otherwise hard to know what PC to store
    when(exe_reg_valid && (exe_reg_exc || exe_inst_exc || exe_any_exc)) {
      exe_exception := true.B
      if(conf.regEvec) { stall_count(io.exe_tid) := 1.U }
      else { stall_count(io.exe_tid) := 0.U }
    }
    exe_exception_cause := Mux(exe_reg_exc, exe_reg_cause,
                           Mux(exe_inst_exc, exe_inst_cause, exe_any_cause))
  }

  // Without bypassing, no other instructions from the same thread can be in the
  // pipeline, just override all previous logic
  if(!conf.bypassing) {
    exe_flush := false.B
    dec_stall := false.B
    stall_count := 0.U // until any logic needs >= 3
  }

  // stats
  val exe_cycle = Wire(Bool())
  exe_cycle := false.B // default value
  val exe_instret = Wire(Bool())
  exe_instret := false.B // default value
  if(conf.stats) {
    exe_cycle := RegNext(RegNext(RegNext(next_valid)))
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

