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
  val dec_imm_sel        = UInt(OUTPUT, IMM_WI)
  val dec_op1_sel        = UInt(OUTPUT, OP1_WI)
  val dec_op2_sel        = UInt(OUTPUT, OP2_WI)
  val exe_base_sel       = UInt(OUTPUT, BASE_WI)
  val exe_op1_rs1        = Bool(OUTPUT)
  val exe_op2_rs2        = Bool(OUTPUT)
  val exe_alu_type       = UInt(OUTPUT, ALU_WI)
  val exe_csr_type       = UInt(OUTPUT, CSR_WI)
  val exe_rd_data_sel    = UInt(OUTPUT, EXE_RD_WI)
  val exe_mem_type       = UInt(OUTPUT, MEM_WI)
  val mem_rd_data_sel    = UInt(OUTPUT, MEM_RD_WI)
  
  // outputs to datapath (control dependent)
  val next_pc_sel        = Vec.fill(conf.threads) { UInt(OUTPUT, NPC_WI) }
  val next_tid           = UInt(OUTPUT, conf.threadBits)
  val next_valid         = Bool(OUTPUT)
  val dec_rs1_sel        = UInt(OUTPUT, RS1_WI)
  val dec_rs2_sel        = UInt(OUTPUT, RS2_WI)
  val dec_replay         = Bool(OUTPUT)
  val exe_load           = Bool(OUTPUT)
  val exe_store          = Bool(OUTPUT)
  val exe_csr_write      = Bool(OUTPUT)
  val mem_rd_write       = Bool(OUTPUT)

  // inputs from datapath
  val if_tid      = UInt(INPUT, conf.threadBits)
  val dec_tid     = UInt(INPUT, conf.threadBits)
  val dec_inst    = Bits(INPUT, 32)
  val exe_br_cond = Bool(INPUT)
  val exe_tid     = UInt(INPUT, conf.threadBits)
  val exe_rd_addr = UInt(INPUT, REG_ADDR_BITS)
  val csr_slots   = Vec.fill(8) { UInt(INPUT, SLOT_WI) }
  val csr_tmodes  = Vec.fill(conf.threads) { UInt(INPUT, TMODE_WI) }
  val mem_tid     = UInt(INPUT, conf.threadBits)
  val mem_rd_addr = UInt(INPUT, REG_ADDR_BITS)
  val wb_tid      = UInt(INPUT, conf.threadBits)
  val wb_rd_addr  = UInt(INPUT, REG_ADDR_BITS)
}

class Control(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new ControlDatapathIO()
 
  // ************************************************************
  // Decode instruction

  //               legal             imm_sel                                               exe_rd_data_sel
  //               |  branch         |      base_sel                                       |           mem_type
  //               |  |  jump        |      |         op1_sel                              |           |        mem_rd_data_sel
  //               |  |  |  rs1_en   |      |         |        op2_sel                     |           |        |           fence
  //               |  |  |  |  rs2_en|      |         |        |        alu_type           |           |        |           |  fence_i
  //               |  |  |  |  |  rd_en     |         |        |        |         csr_type |           |        |           |  |  scall
  //               |  |  |  |  |  |  |      |         |        |        |         |        |           |        |           |  |  |                   
  val default = 
              List(F, F, F, F, F, F, IMM_X, BASE_X,   OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F)
  val decode_table = Array(             
    LUI    -> List(T, F, F, F, F, T, IMM_U, BASE_X,   OP1_0,   OP2_IMM, ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    AUIPC  -> List(T, F, F, F, F, T, IMM_U, BASE_X,   OP1_PC,  OP2_IMM, ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    JAL    -> List(T, F, T, F, F, T, IMM_J, BASE_PC,  OP1_PC,  OP2_4,   ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    JALR   -> List(T, F, T, T, F, T, IMM_I, BASE_RS1, OP1_PC,  OP2_4,   ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    BEQ    -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SEQ,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    BNE    -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SNE,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    BLT    -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SLT,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    BGE    -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SGE,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    BLTU   -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SLTU, CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    BGEU   -> List(T, T, F, T, T, F, IMM_B, BASE_PC,  OP1_RS1, OP2_RS2, ALU_SGEU, CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, F),
    LB     -> List(T, F, F, T, F, T, IMM_I, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_LB,  MEM_RD_MEM, F, F, F),
    LH     -> List(T, F, F, T, F, T, IMM_I, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_LH,  MEM_RD_MEM, F, F, F),
    LW     -> List(T, F, F, T, F, T, IMM_I, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_LW,  MEM_RD_MEM, F, F, F),
    LBU    -> List(T, F, F, T, F, T, IMM_I, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_LBU, MEM_RD_MEM, F, F, F),
    LHU    -> List(T, F, F, T, F, T, IMM_I, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_LHU, MEM_RD_MEM, F, F, F),
    SB     -> List(T, F, F, T, T, F, IMM_S, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_SB,  MEM_RD_X  , F, F, F),
    SH     -> List(T, F, F, T, T, F, IMM_S, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_SH,  MEM_RD_X  , F, F, F),
    SW     -> List(T, F, F, T, T, F, IMM_S, BASE_RS1, OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_SW,  MEM_RD_X  , F, F, F),
    ADDI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLTI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_SLT,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLTIU  -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_SLTU, CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    XORI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_XOR,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    ORI    -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_OR,   CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    ANDI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_AND,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLLI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_SLL,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SRLI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_SRL,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SRAI   -> List(T, F, F, T, F, T, IMM_I, BASE_X,   OP1_RS1, OP2_IMM, ALU_SRA,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    ADD    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_ADD,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SUB    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SUB,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLL    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SLL,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLT    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SLT,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SLTU   -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SLTU, CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    XOR    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_XOR,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SRL    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SRL,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    SRA    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_SRA,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    OR     -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_OR,   CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    AND    -> List(T, F, F, T, T, T, IMM_X, BASE_X,   OP1_RS1, OP2_RS2, ALU_AND,  CSR_F,   EXE_RD_ALU, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRW  -> List(T, F, F, T, F, T, IMM_X, BASE_X,   OP1_RS1, OP2_0,   ALU_ADD,  CSR_W,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRS  -> List(T, F, F, T, F, T, IMM_X, BASE_X,   OP1_RS1, OP2_0,   ALU_ADD,  CSR_S,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRC  -> List(T, F, F, T, F, T, IMM_X, BASE_X,   OP1_RS1, OP2_0,   ALU_ADD,  CSR_C,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRWI -> List(T, F, F, F, F, T, IMM_Z, BASE_X,   OP1_0,   OP2_IMM, ALU_ADD,  CSR_W,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRSI -> List(T, F, F, F, F, T, IMM_Z, BASE_X,   OP1_0,   OP2_IMM, ALU_ADD,  CSR_S,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    CSRRCI -> List(T, F, F, F, F, T, IMM_Z, BASE_X,   OP1_0,   OP2_IMM, ALU_ADD,  CSR_C,   EXE_RD_CSR, MEM_F,   MEM_RD_REG, F, F, F),
    FENCE  -> List(T, F, F, F, F, F, IMM_X, BASE_X,   OP1_X,   OP2_X,   ALU_ADD,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , T, F, F),
    FENCE_I-> List(T, F, F, F, F, F, IMM_X, BASE_X,   OP1_X,   OP2_X,   ALU_ADD,  CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, T, F),
    SCALL  -> List(T, F, F, F, F, F, IMM_X, BASE_X,   OP1_X,   OP2_X,   ALU_X,    CSR_F,   EXE_RD_X,   MEM_F,   MEM_RD_X  , F, F, T)
  )

  //val decoded_inst = ListLookup(io.dec_inst, default, decode_table)
  val decoded_inst = DecodeLogic(io.dec_inst, default, decode_table)

  // decoded information
  val dec_legal :: dec_branch :: dec_jump :: dec_rs1_en :: dec_rs2_en :: dec_rd_en :: dec_imm_sel :: dec_base_sel :: dec_op1_sel :: dec_op2_sel :: dec_alu_type :: dec_csr_type :: dec_exe_rd_data_sel :: dec_mem_type :: dec_mem_rd_data_sel :: dec_fence :: dec_fence_i :: dec_scall :: Nil = decoded_inst
  
  // ************************************************************
  // Decoded control signals for datapath operation of stages after decode, 
  // independent of control flow (i.e. even if instruction killed)
  val exe_reg_base_sel = Reg(next = dec_base_sel)
  val exe_reg_op1_rs1 = Reg(next = (dec_op1_sel === OP1_RS1))
  val exe_reg_op2_rs2 = Reg(next = (dec_op2_sel === OP2_RS2))
  val exe_reg_alu_type = Reg(next = dec_alu_type)
  val exe_reg_csr_type = Reg(next = dec_csr_type)
  val exe_reg_rd_data_sel = Reg(next = dec_exe_rd_data_sel)
  val exe_reg_mem_type = Reg(next = dec_mem_type)
  val mem_reg_rd_data_sel = Reg(next = Reg(next = dec_mem_rd_data_sel))

  io.dec_imm_sel        := dec_imm_sel
  io.dec_op1_sel        := dec_op1_sel
  io.dec_op2_sel        := dec_op2_sel
  io.exe_base_sel       := exe_reg_base_sel
  io.exe_op1_rs1        := exe_reg_op1_rs1
  io.exe_op2_rs2        := exe_reg_op2_rs2
  io.exe_alu_type       := exe_reg_alu_type
  io.exe_csr_type       := exe_reg_csr_type
  io.exe_rd_data_sel    := exe_reg_rd_data_sel
  io.exe_mem_type       := exe_reg_mem_type
  io.mem_rd_data_sel    := mem_reg_rd_data_sel


  // ************************************************************
  // control flow dependent

  // Set true to kill/replay stage (only has effect if thread IDs match).
  // Commit point is end of execute stage (store to memory or CSR).
  // Note: If instruction killed, exception cannot occur for it.
  val dec_if_kill  = Bool()
  val exe_if_kill  = Bool()
  val mem_if_kill  = Bool()
  val exe_dec_kill = Bool()
  val dec_replay   = Bool() //TODO: careful with if_kill at same time
  val exe_kill     = Bool()
  // default values
  dec_if_kill  := Bool(false)
  exe_if_kill  := Bool(false)
  exe_dec_kill := Bool(false)
  exe_kill     := Bool(false)
  dec_replay   := Bool(false)
 
  // Current status of each stage (valid if previous stage was valid and no kill
  // on current stage).
  val next_valid    = Bool()
  val if_reg_valid  = Reg(next = next_valid, init = Bool(false))
  val if_valid      = if_reg_valid  && 
                      !(dec_if_kill && (io.dec_tid === io.if_tid)) &&
                      !(exe_if_kill && (io.exe_tid === io.if_tid)) &&
                      !(mem_if_kill && (io.mem_tid === io.if_tid))
  val dec_reg_valid = Reg(next = if_valid,   init = Bool(false))
  val dec_valid     = dec_reg_valid &&
                      !(exe_dec_kill && (io.exe_tid === io.dec_tid))
  val exe_reg_valid = Reg(next = dec_valid,  init = Bool(false))
  val exe_valid     = exe_reg_valid && !exe_kill
  val mem_reg_valid = Reg(next = exe_valid,  init = Bool(false))
  val mem_valid     = mem_reg_valid
  val wb_reg_valid  = Reg(next = mem_valid,  init = Bool(false))
  val wb_valid      = wb_reg_valid

  // Thread scheduling uses current state and control registers (slots and
  // tmodes).
  val next_tid    = UInt()
  val scheduler = Module(new Scheduler())
  scheduler.io.slots := io.csr_slots
  scheduler.io.thread_modes := io.csr_tmodes
  next_tid := scheduler.io.thread
  next_valid := scheduler.io.valid

  // Keep track of address and decision to write to rd.
  val dec_rd_write = (io.dec_inst(11, 7) != UInt(0)) && dec_rd_en.toBool
  val exe_reg_rd_write = Reg(next = dec_rd_write && dec_valid)
  val mem_reg_rd_write = Reg(next = exe_reg_rd_write && exe_valid)
  val wb_reg_rd_write  = Reg(next = mem_reg_rd_write) // no kill allowed in mem or wb stage

  // Forwarding logic for rs1 and rs2
  // Assume rs1/rs2 select doesn't matter if execute stage killed (don't need to wait on exe_valid signal).
  val dec_rs1_addr = io.dec_inst(19, 15)
  val dec_rs2_addr = io.dec_inst(24, 20)
  val dec_check_exe = (io.dec_tid === io.exe_tid) && exe_reg_rd_write
  val dec_check_mem = (io.dec_tid === io.mem_tid) && mem_reg_rd_write
  val dec_check_wb  = (io.dec_tid === io.wb_tid)  && wb_reg_rd_write
  val dec_rs1_sel = 
    Mux(dec_check_exe && (dec_rs1_addr === io.exe_rd_addr), RS1_EXE,
    Mux(dec_check_mem && (dec_rs1_addr === io.mem_rd_addr), RS1_MEM,
    Mux(dec_check_wb  && (dec_rs1_addr === io.wb_rd_addr),  RS1_WB,
    RS1_DEC)))
  val dec_rs2_sel = 
    Mux(dec_check_exe && (dec_rs2_addr === io.exe_rd_addr), RS2_EXE,
    Mux(dec_check_mem && (dec_rs2_addr === io.mem_rd_addr), RS2_MEM,
    Mux(dec_check_wb  && (dec_rs2_addr === io.wb_rd_addr),  RS2_WB,
    RS2_DEC)))

  // Keep track of load/store.
  val dec_load = dec_valid && ((dec_mem_type === MEM_LB) || (dec_mem_type === MEM_LH) || (dec_mem_type === MEM_LW) || (dec_mem_type === MEM_LBU) || (dec_mem_type === MEM_LHU))
  val exe_reg_load = Reg(next = dec_load)
  val exe_load = exe_valid && exe_reg_load
  val dec_store = dec_valid && ((dec_mem_type === MEM_SB) || (dec_mem_type === MEM_SH) || (dec_mem_type === MEM_SW))
  val exe_reg_store = Reg(next = dec_store)
  val exe_store = exe_valid && exe_reg_store

  // Kep track of write to CSR
  val exe_reg_csr_write = Reg(next = (dec_csr_type != CSR_F))
  val exe_csr_write = exe_valid && exe_reg_csr_write

  // Detect a load-use case (result isn't available until memory stage and stall
  // is needed to prevent hazard if instruction from same thread is following stage).
  val exe_reg_load_use = Reg(next = (dec_load))
  when(exe_reg_load_use && (
         (dec_rs1_en.toBool && (dec_rs1_sel === RS1_EXE)) || 
         (dec_rs2_en.toBool && (dec_rs2_sel === RS2_EXE)) )) {
    exe_dec_kill := Bool(true)
    // If fetch stage belongs to the same thread, decode stage can be replayed.
    when(io.if_tid === io.dec_tid) { 
      // if fetch is killed, replay will not be valid
      dec_replay := Bool(true) 
    }
  }

  // For each stage, keep track of high priority exception.
  val if_exception = Bool()
  val if_cause = UInt()
  val dec_exception = Bool()
  val dec_cause = UInt()
  val exe_exception = Bool()
  val exe_cause = UInt()
  val dec_reg_exception = Reg(next = if_exception)
  val dec_reg_cause = Reg(next = if_cause)
  val exe_reg_exception = Reg(next = dec_exception)
  val exe_reg_cause = Reg(next = dec_cause)

  // Detect fetch stage exceptions.
  if_exception := Bool(false)
  if_cause := CAUSE_X
  // TODO: address misaligned or access fault
  // when()...

  // Detect decode stage exceptions.
  dec_exception := dec_reg_exception
  dec_cause := dec_reg_cause
  // TODO: add more
  when(!dec_legal.toBool) { 
    dec_exception := Bool(true)
    //dec_cause := CAUSE_ILLEGAL
  } .elsewhen(dec_scall.toBool) {
    dec_exception := Bool(true)
    //dec_cause := CAUSE_SCALL
  }

  // Detect execute stage exceptions.
  exe_exception := exe_reg_exception
  exe_cause := exe_reg_cause
  // TODO: add more
  // when()...

  // Handle all exceptions in execute stage.
  val exe_evec = Bool()
  exe_evec := Bool(false)
  when(exe_reg_valid && exe_exception) {
    exe_evec := Bool(true)
    exe_if_kill := Bool(true)
    exe_dec_kill := Bool(true)
    // exe_kill := Bool(true)
    // TODO: cause, pc
  }
  
  // Keep track of branch/jump instruction.
  val exe_reg_branch = Reg(next = dec_branch.toBool)
  val exe_reg_jump = Reg(next = dec_jump.toBool)
  val exe_brjmp = exe_valid && (exe_reg_jump || (exe_reg_branch && io.exe_br_cond))
                  
  // Determine how to update PC for each thread. 
  val next_pc_sel = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) { next_pc_sel := NPC_PCREG }
  when(if_valid && !dec_replay) { next_pc_sel(io.if_tid)  := NPC_PLUS4 }
  when(exe_brjmp)               { next_pc_sel(io.exe_tid) := NPC_BRJMP }
  if(conf.exceptions) {
    when(exe_evec)              { next_pc_sel(io.exe_tid) := NPC_EVEC  }
  }
  //for((next, i) <- next_pc_sel.view.zipWithIndex) {
    //next := NPC_PCREG
    //when(if_valid && (UInt(i) === io.if_tid) && !dec_replay) { next := NPC_PLUS4 }
    //when(exe_brjmp && (UInt(i) === io.exe_tid)) { next := NPC_BRJMP }
    //if(conf.exceptions) {
    //  when(dec_exception(i) || exe_exception(i)) { next := NPC_EVEC } //ifex
    //}
  //}

  // If branch taken, kill any instructions from same thread in pipeline
  when(exe_brjmp) {
    exe_if_kill := Bool(true)
    exe_dec_kill := Bool(true)
  }

  // Static multicycle support by killing instructions with same thread ID for
  // set number of cycles.
  // Note: If need support for more than a few cycles, switch to counters with
  // mux.
  
  val exe_reg_if_kill = Reg(next = dec_fence_i.toBool)
  //val mem_reg_if_kill = Reg(next = Reg(next = ))

  when(dec_fence_i.toBool) {
    dec_if_kill := Bool(true) //TODO: check
  }
  when(exe_reg_valid && exe_reg_if_kill) {
    exe_if_kill := Bool(true)
  }

  // A simple implementation of the FENCE.I instruction is to prevent the
  // thread from fetching or executing another instruction until the 
  // FENCE.I instruction has completed execute stage (so any preceding 
  // instruction has completed at least memory stage). This can be done by
  // killing any instruction with the same thread ID in fetch for 2 cycles.

  // to datapath
  io.next_tid           := next_tid
  io.next_valid         := next_valid
  io.next_pc_sel        := next_pc_sel
  io.dec_rs1_sel        := dec_rs1_sel
  io.dec_rs2_sel        := dec_rs2_sel
  io.dec_replay         := dec_replay
  io.exe_load           := exe_load
  io.exe_store          := exe_store
  io.exe_csr_write      := exe_csr_write
  io.mem_rd_write       := mem_reg_rd_write

}

