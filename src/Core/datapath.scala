/******************************************************************************
 * File: datapath.scala
 * Description: Datapath
 * Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
 * Contributors: 
 * License: See LICENSE.txt
 * ******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

class Datapath(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new Bundle {
    val control = new ControlDatapathIO().flip
    val imem = new InstMemCoreIO().flip
    val dmem = new DataMemCoreIO().flip
    val bus  = new BusIO().flip
    val host = new HostIO()
  }

  // ************************************************************
  // Pipeline Registers and Cross-Stage Signals

  // instruction fetch stage
  val if_reg_tid            = Reg(UInt())
  val if_reg_pcs            = Vec.fill(conf.threads) { Reg(init = ADDR_PC_INIT.toUInt) } // PC for each thread

  val if_pc_plus4           = UInt()

  // decode stage
  val dec_reg_tid           = Reg(UInt())
  val dec_reg_pc            = Reg(UInt())
  val dec_reg_inst          = Reg(Bits())

  // execute stage
  val exe_reg_tid           = Reg(UInt())
  val exe_reg_rd_addr       = Reg(UInt())
  val exe_reg_op1           = Reg(UInt()) // either rs1 (mux after reg), PC, or 0
  val exe_reg_op2           = Reg(UInt()) // either rs2 (mux after reg), sign-extended immediate, or 4
  val exe_reg_rs1_data      = Reg(Bits()) // rs1/rs2 compare, alu op1/op2
  val exe_reg_rs2_data      = Reg(Bits()) // data for store
  val exe_reg_pc            = Reg(UInt()) // used for address base, exceptions
  val exe_reg_imm           = Reg(UInt()) // used for address offset, csr data
  val exe_reg_csr_addr      = Reg(UInt())
  // TODO val exe_reg_multicycle  = Vec.fill(conf.threads) { Reg(Bits()) }

  val exe_alu_result        = Bits()
  val exe_address           = UInt()
  val exe_rd_data           = Bits()
  val exe_evec              = UInt() //ifex

  // memory stage
  val mem_reg_tid           = Reg(UInt())
  val mem_reg_rd_addr       = Reg(UInt())
  val mem_reg_rd_data       = Reg(Bits()) // result from execute stage

  val mem_rd_data            = Bits()
  
  // writeback stage
  val wb_reg_tid            = Reg(UInt())
  val wb_reg_rd_addr        = Reg(UInt())
  val wb_reg_rd_data        = Reg(Bits())

  val wb_rd_data             = Bits()

  // ************************************************************
  // Next PCs Generation

  // For each thread, determine next input to its PC register.
  val next_pcs = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) { next_pcs(tid) := if_reg_pcs(tid) }
  when(io.control.next_pc_sel(if_reg_tid) === NPC_PLUS4) {
    next_pcs(if_reg_tid) := if_pc_plus4
  }
  when(io.control.next_pc_sel(exe_reg_tid) === NPC_BRJMP) {
    next_pcs(exe_reg_tid) := exe_address
  }
  if(conf.exceptions) {
    when(io.control.next_pc_sel(exe_reg_tid) === NPC_EVEC) {
      next_pcs(exe_reg_tid) := exe_evec
    }
  }
  
  // Provide next PC address (PC of scheduled thread) to instruction memory.
  // Note: For all SRAMs, input provided at end of clock cycle so data
  // will become available in the next clock cycle.
  io.imem.r.addr := next_pcs(io.control.next_tid)(31, 2)
  io.imem.r.enable := io.control.next_valid
  
  // Provide inputs to fetch stage registers.
  if_reg_tid := io.control.next_tid
  if_reg_pcs := next_pcs

  // ************************************************************
  // Instruction Fetch Stage

  // Compute PC+4 of fetched thread.
  val if_pc = if_reg_pcs(if_reg_tid)
  if_pc_plus4 := if_pc + UInt(4)

  // Instruction is either returned by instruction memory or replayed.
  val if_inst = Mux(io.control.dec_replay, dec_reg_inst, io.imem.r.data_out)
  val if_tid = if_reg_tid // No mux, replay only occurs if if_tid === dec_tid.

  // Provide rs1 and rs2 address to register file (bit location is constant so
  // it can be done before instruction is decoded).
  val regfile = Module(new RegisterFile())
  regfile.io.rs1.thread := if_tid
  regfile.io.rs1.addr := if_inst(19, 15)
  regfile.io.rs2.thread := if_tid
  regfile.io.rs2.addr := if_inst(24, 20)

  // Provide data to control.
  io.control.if_tid := if_tid

  // Provide inputs to decode stage registers.
  dec_reg_tid := if_tid
  dec_reg_pc := Mux(io.control.dec_replay, dec_reg_pc, if_pc)
  dec_reg_inst := if_inst


  // ************************************************************
  // Decode Stage

  // rs1 and rs2 are returned by register file, but updated value may need to be
  // forwarded from later stages.
  val dec_rs1_data = MuxLookup(io.control.dec_rs1_sel, regfile.io.rs1.data, Array(
    RS1_EXE -> exe_rd_data,
    RS1_MEM -> mem_rd_data,
    RS1_WB  -> wb_rd_data //,
    //RS1_DEC -> regfile.io.rs1.data //FIXME: causes chisel verilog bug
    ))
  val dec_rs2_data = MuxLookup(io.control.dec_rs2_sel, regfile.io.rs2.data, Array(
    RS2_EXE -> exe_rd_data,
    RS2_MEM -> mem_rd_data,
    RS2_WB  -> wb_rd_data //,
    //RS2_DEC -> regfile.io.rs2.data //FIXME: causes chisel verilog bug
    ))

  // Generate immediate values.
  val dec_imm_i = Cat(Fill(21, dec_reg_inst(31)), dec_reg_inst(30, 20))
  val dec_imm_s = Cat(Fill(21, dec_reg_inst(31)), dec_reg_inst(30, 25), dec_reg_inst(11,7))
  val dec_imm_b = Cat(Fill(20, dec_reg_inst(31)), dec_reg_inst(7), dec_reg_inst(30, 25), dec_reg_inst(11, 8), Bits(0, 1))
  val dec_imm_u = Cat(dec_reg_inst(31,12), Bits(0, 12))
  val dec_imm_j = Cat(Fill(12, dec_reg_inst(31)), dec_reg_inst(19, 12), dec_reg_inst(20), dec_reg_inst(30, 21), Bits(0, 1))
  // For CSR
  val dec_imm_z = Cat(Bits(0, 27), dec_reg_inst(19, 15)) 

  val dec_imm = MuxLookup(io.control.dec_imm_sel, dec_imm_i, Array(
    IMM_S -> dec_imm_s,
    IMM_B -> dec_imm_b,
    IMM_U -> dec_imm_u,
    IMM_J -> dec_imm_j,
    IMM_I -> dec_imm_i,
    IMM_Z -> dec_imm_z
  ))

  // Set operands for ALU.
  // Note: rs1/rs2 muxes in next stage.
  val dec_op1 = Mux(io.control.dec_op1_sel === OP1_PC, dec_reg_pc, Bits(0, 32)) // default: OP1_0
  val dec_op2 = Mux(io.control.dec_op2_sel === OP2_IMM, dec_imm,
                Mux(io.control.dec_op2_sel === OP2_4, Bits(4, 32),
                    Bits(0, 32))) // default: OP2_0

  // Provide data to control.
  io.control.dec_tid  := dec_reg_tid
  io.control.dec_inst := dec_reg_inst

  // Provide inputs to execute stage registers.
  exe_reg_tid      := dec_reg_tid
  exe_reg_rd_addr  := dec_reg_inst(11, 7)
  exe_reg_op1      := dec_op1
  exe_reg_op2      := dec_op2
  exe_reg_rs1_data := dec_rs1_data
  exe_reg_rs2_data := dec_rs2_data
  exe_reg_pc       := dec_reg_pc
  exe_reg_imm      := dec_imm
  exe_reg_csr_addr := dec_reg_inst(31, 20)

  
  // ************************************************************
  // Execute Stage
  
  // ALU
  // TODO: optimize?
  val exe_op1 = Mux(io.control.exe_op1_rs1, exe_reg_rs1_data, exe_reg_op1)
  val exe_op2 = Mux(io.control.exe_op2_rs2, exe_reg_rs2_data, exe_reg_op2)
  val exe_alu_shift = exe_op2(4, 0)
  val def_exe_alu_result = exe_op1 + exe_op2
  exe_alu_result := MuxLookup(io.control.exe_alu_type, def_exe_alu_result, Array(
    ALU_ADD ->  (exe_op1 + exe_op2),
    ALU_SLL ->  (exe_op1 << exe_alu_shift)(32-1, 0),
    ALU_XOR ->  (exe_op1 ^ exe_op2),
    ALU_SRL ->  (exe_op1 >> exe_alu_shift),
    ALU_OR  ->  (exe_op1 | exe_op2),
    ALU_AND ->  (exe_op1 & exe_op2),
    ALU_SUB ->  (exe_op1 - exe_op2),
    ALU_SLT ->  (exe_op1.toSInt < exe_op2.toSInt),
    ALU_SLTU -> (exe_op1 < exe_op2),
    ALU_SRA ->  (exe_op1.toSInt >> exe_alu_shift),
    // Branching conditions with ALU
    ALU_SEQ ->  (if(!conf.dedicatedBranchCheck) (exe_op1 === exe_op2) else def_exe_alu_result),
    ALU_SNE ->  (if(!conf.dedicatedBranchCheck) (exe_op1 != exe_op2) else def_exe_alu_result),
    ALU_SGE ->  (if(!conf.dedicatedBranchCheck) (exe_op1.toSInt >= exe_op2.toSInt) else def_exe_alu_result),
    ALU_SGEU -> (if(!conf.dedicatedBranchCheck) (exe_op1 >= exe_op2) else def_exe_alu_result)
  ))
    
  // Check branch condition.
  val exe_br_cond = Bool()
  if(conf.dedicatedBranchCheck) {
    val exe_lt = exe_reg_rs1_data.toSInt < exe_reg_rs2_data.toSInt
    val exe_ltu = exe_reg_rs1_data < exe_reg_rs2_data
    val exe_eq = exe_reg_rs1_data === exe_reg_rs2_data
    val def_exe_br_cond = Bool(false)
    exe_br_cond := MuxLookup(io.control.exe_alu_type, def_exe_br_cond, Array(
      ALU_SEQ  -> exe_eq,
      ALU_SLT  -> exe_lt,
      ALU_SLTU -> exe_ltu,
      ALU_SNE  -> !exe_eq,
      ALU_SGE  -> !exe_lt,
      ALU_SGEU -> !exe_ltu
    ))
  } else {
    // Assume control puts rs1 and rs2 in op1 and op2
    // and alu_type is correctly set.
    exe_br_cond := exe_alu_result(0).toBool 
  }

  // Branch/jump target address calculation.
  // B*: PC + imm_b; JAL: PC + imm_j; JALR: rs1 + imm_i
  // Note: Separate because ALU needs to be used for PC + 4/U
  val exe_base = Mux(io.control.exe_base_sel === BASE_RS1, exe_reg_rs1_data, exe_reg_pc) // default: BASE_PC
  val exe_offset = exe_reg_imm
  exe_address := exe_base + exe_offset
 
  val loadstore = Module(new LoadStore())
  // memories and bus
  loadstore.io.dmem <> io.dmem
  loadstore.io.imem.rw <> io.imem.rw
  loadstore.io.bus <> io.bus
  // datapath inputs
  loadstore.io.addr     := exe_address
  loadstore.io.data_in  := exe_reg_rs2_data
  loadstore.io.load     := io.control.exe_load
  loadstore.io.store    := io.control.exe_store
  loadstore.io.mem_type := io.control.exe_mem_type
  
 // *****
  val csr = Module(new CSR())
  val exe_csr_data = exe_alu_result.toBits
  csr.io.rw.addr := exe_reg_csr_addr
  csr.io.rw.thread := exe_reg_tid
  csr.io.rw.csr_type := io.control.exe_csr_type
  csr.io.rw.write := io.control.exe_csr_write
  csr.io.rw.data_in := exe_csr_data
 
  if(conf.exceptions) {
    exe_evec := csr.io.evec //ifex
  }
  
  // Only keep needed result for rd.
  exe_rd_data := Mux(io.control.exe_rd_data_sel === EXE_RD_CSR, csr.io.rw.data_out, 
                     exe_alu_result) // default: EXE_RD_ALU
 
  // Provide data to control.
  io.control.exe_br_cond := exe_br_cond
  io.control.exe_tid     := exe_reg_tid
  io.control.exe_rd_addr := exe_reg_rd_addr
    
  // Provide inputs to memory stage registers.
  mem_reg_tid     := exe_reg_tid
  mem_reg_rd_addr := exe_reg_rd_addr
  mem_reg_rd_data  := exe_rd_data
  
  // ************************************************************
  // Memory Stage
 
  // Data to store back to rd can come from execute stage or data memory.
  mem_rd_data := 
    Mux(io.control.mem_rd_data_sel === MEM_RD_MEM, loadstore.io.data_out,
    // MEM_RD_REG
    mem_reg_rd_data)

  // Provide inputs to rd port of register file.
  regfile.io.rd.thread  := mem_reg_tid
  regfile.io.rd.addr    := mem_reg_rd_addr
  regfile.io.rd.data    := mem_rd_data
  regfile.io.rd.enable  := io.control.mem_rd_write
  
  io.control.mem_tid     := mem_reg_tid
  io.control.mem_rd_addr := mem_reg_rd_addr
  
  io.control.csr_slots := csr.io.slots
  io.control.csr_tmodes := csr.io.tmodes
  io.host.to_host := csr.io.host.to_host
  
  wb_reg_tid     := mem_reg_tid
  wb_reg_rd_addr := mem_reg_rd_addr
  wb_reg_rd_data := mem_rd_data
  
  // ************************************************************
  // Writeback Stage
  wb_rd_data := wb_reg_rd_data
  
  io.control.wb_tid     := wb_reg_tid
  io.control.wb_rd_addr := wb_reg_rd_addr

}
