/******************************************************************************
 * File: Datapath.scala
 * Description: Datapath
 * Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
 * Author: Edward Wang (edwardw@eecs.berkeley.edu)
 * License: See LICENSE.txt
 * ******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util._

import Core.Causes
import Core.FlexpretConstants._
import Core.LoadStore
import Core.CSRs

class Datapath(confHash: UInt, val debug: Boolean = false)(implicit conf: FlexpretConfiguration) extends Module {
  val io = IO(new Bundle {
    val control = Flipped(new ControlDatapathIO())
    val imem = Flipped(new InstMemCoreIO())
    val dmem = Flipped(new DataMemCoreIO())
    val bus = Flipped(new BusIO())
    val host = new HostIO()
    val gpio = new GPIO()
    val int_exts = Input(Vec(conf.threads, Bool()))
    val imem_store = Output(Bool())

    // Debugging-only inputs.
    val debugIO = if (!debug) None else Some(new Bundle {
      // Mock register file I/Os for rs1.
      val rs1_thread = Output(UInt())
      val rs1_addr = Output(UInt())
      val rs1_value = Input(UInt(32.W))
      // Mock register file I/Os for rs2.
      val rs2_thread = Output(UInt())
      val rs2_addr = Output(UInt())
      val rs2_value = Input(UInt(32.W))
      // Other pipeline signals.
      val exe_alu_result = Output(UInt())

    })
  })

  // ************************************************************
  // Pipeline Registers and Cross-Stage Signals

  // instruction fetch stage
  val if_reg_tid = Reg(UInt())
  val if_reg_pc = if (conf.threads > 1) Reg(UInt()) else Wire(UInt()) // PC
  val if_reg_pcs = RegInit(VecInit(Seq.fill(conf.threads)(ADDR_PC_INIT))) // PC for each thread

  val if_pc_plus4 = Wire(UInt())

  // decode stage
  val dec_reg_tid = Reg(UInt())
  val dec_reg_pc = Reg(UInt()) // alu op1, exception address
  val dec_reg_pc4 = Reg(UInt()) // rd for JAL*
  val dec_reg_inst = Reg(UInt(32.W)) // decoded by control unit

  // execute stage
  val exe_reg_inst = RegNext(dec_reg_inst) // for debugging
  val exe_reg_tid = Reg(UInt())
  val exe_reg_rd_addr = Reg(UInt())
  val exe_reg_op1 = Reg(UInt()) // either rs1, PC, or 0
  val exe_reg_op2 = Reg(UInt()) // either rs2, immediate, 0, or 4
  val exe_reg_rs1_data = Reg(Bits()) // branch check
  val exe_reg_rs2_data = Reg(Bits()) // branch check, store data
  val exe_reg_pc = Reg(UInt()) // exception address
  val exe_reg_pc4 = Reg(UInt()) // rd for JAL*
  val exe_reg_csr_addr = Reg(UInt())
  val exe_reg_csr_data = Reg(UInt())

  val exe_alu_result = Wire(UInt(32.W))
  io.debugIO.map { b => b.exe_alu_result := exe_alu_result }
  val exe_address = Wire(UInt())
  val exe_rd_data = Wire(UInt())
  val exe_evec = Wire(UInt()) // trap handler address
  
  // return of trap address for the three differnet priviledge modes
  val exe_mepc  = Wire(UInt())

  // memory stage
  val mem_reg_tid = Reg(UInt())
  val mem_reg_rd_addr = Reg(UInt())
  val mem_reg_rd_data = Reg(UInt()) // result from execute stage
  val mem_reg_address = Reg(UInt())
  val mem_evec = Wire(UInt())
  val mem_mepc  = Wire(UInt())

  val mem_rd_data = Wire(UInt())

  // writeback stage
  val wb_reg_tid = Reg(UInt())
  val wb_reg_rd_addr = Reg(UInt())
  val wb_reg_rd_data = Reg(UInt())

  val wb_rd_data = Wire(UInt())

  // ************************************************************
  // Next PCs Generation

  // For each thread, determine next input to its PC register.
  val next_pcs = Wire(Vec(conf.threads, UInt()))
  for (tid <- 0 until conf.threads) {
    next_pcs(tid) := if_reg_pcs(tid)
  } // default value
  when(io.control.next_pc_sel(if_reg_tid) === NPC_PLUS4) {
    next_pcs(if_reg_tid) := if_pc_plus4
  }
  if (!conf.regBrJmp) {
    when(io.control.next_pc_sel(exe_reg_tid) === NPC_BRJMP) {
      next_pcs(exe_reg_tid) := exe_address
    }
  } else {
    when(io.control.next_pc_sel(mem_reg_tid) === NPC_BRJMP) {
      next_pcs(mem_reg_tid) := mem_reg_address
    }
  }
  // higher priority than BRJMP
  if (conf.exceptions) {
    if (!conf.regEvec) {
      when(io.control.next_pc_sel(exe_reg_tid) === NPC_CSR) {
        when(io.control.next_pc_sel_csr_addr === CSRs.evec.U) {
          next_pcs(exe_reg_tid) := exe_evec
        }
      }
    } else {
      when(io.control.next_pc_sel(mem_reg_tid) === NPC_CSR) {
        when(io.control.next_pc_sel_csr_addr === CSRs.evec.U) {
          next_pcs(mem_reg_tid) := mem_evec
        }
      }
    }
  }

  when(io.control.next_pc_sel(exe_reg_tid) === NPC_CSR) {
    when(io.control.next_pc_sel_csr_addr === CSRs.mepc.U) {
      next_pcs(exe_reg_tid) := exe_mepc
    }
  }

  // Provide next PC address (PC of scheduled thread) to instruction memory.
  // Note: For all SRAMs, input provided at end of clock cycle so data
  // will become available in the next clock cycle.
  val next_tid = io.control.next_tid
  val next_pc = next_pcs(next_tid)
  // TODO: best way to handle 4t-rr w/ reg*?
  //val next_pc = if(conf.bypassing) next_pcs(next_tid) else if_reg_pcs(next_tid)
  io.imem.r.addr := next_pc(31, 2)
  io.imem.r.enable := (if (conf.iMemForceEn) true.B else io.control.next_valid)

  // Provide inputs to fetch stage registers. 'if_reg_pc' is redundant, but
  // prevents needing to demux all the PCs a 2nd time in the fetch stage.
  if_reg_tid := next_tid
  if_reg_pc := (if (conf.threads > 1) next_pc else if_reg_pcs(0))
  if_reg_pcs := next_pcs

  // ************************************************************
  // Instruction Fetch Stage

  // Compute PC+4 of fetched thread.
  if_pc_plus4 := if_reg_pc + 4.U

  // Instruction is returned by instruction memory.
  val if_inst = io.imem.r.data_out

  // Provide rs1 and rs2 address to register file (bit location is constant so
  // it can be done before instruction is decoded).
  val regfile = Module(RegisterFile(readPorts = 2, writePorts = 1))
  regfile.io.read(0).thread := if_reg_tid
  if (debug) io.debugIO.get.rs1_thread := regfile.io.read(0).thread
  regfile.io.read(0).addr := if_inst(19, 15)
  if (debug) io.debugIO.get.rs1_addr := regfile.io.read(0).addr
  regfile.io.read(1).thread := if_reg_tid
  if (debug) io.debugIO.get.rs2_thread := regfile.io.read(1).thread
  regfile.io.read(1).addr := if_inst(24, 20)
  if (debug) io.debugIO.get.rs2_addr := regfile.io.read(1).addr

  // Provide data to control.
  io.control.if_tid := if_reg_tid

  // Exception checks
  if (conf.causes.contains(Causes.misaligned_fetch)) {
    // Lower 2 bits should be 0
    io.control.if_exc_misaligned := if_reg_pc(1, 0) =/= 0.U
  } else {
    io.control.if_exc_misaligned := false.B
  }
  if (conf.causes.contains(Causes.fault_fetch)) {
    // PC should be in memory space of I-SPM
    //spike: rm
    io.control.if_exc_fault := if_reg_pc(31, conf.iMemAddrBits + 2) =/= Cat(ADDR_ISPM_VAL, 0.U((30 - ADDR_ISPM_BITS - conf.iMemAddrBits).W))
  } else {
    io.control.if_exc_fault := false.B
  }

  // Provide inputs to decode stage registers.
  dec_reg_tid := if_reg_tid
  dec_reg_pc := if_reg_pc
  dec_reg_pc4 := if_pc_plus4
  dec_reg_inst := if_inst


  // ************************************************************
  // Decode Stage

  // rs1 and rs2 are returned by register file, but updated value may need to be
  // forwarded from later stages.
  val dec_rs1_data = Wire(Bits())
  val dec_rs2_data = Wire(Bits())
  val regfile_rs1_data = if (debug) io.debugIO.get.rs1_value else regfile.io.read(0).data
  val regfile_rs2_data = if (debug) io.debugIO.get.rs2_value else regfile.io.read(1).data
  if (conf.bypassing) {
    dec_rs1_data := MuxLookup(io.control.dec_rs1_sel, regfile_rs1_data, Array(
      RS1_EXE -> exe_rd_data,
      RS1_MEM -> mem_rd_data,
      RS1_WB -> wb_rd_data //,
      //RS1_DEC -> regfile_rs1_data //FIXME: causes chisel verilog bug
    ))
    dec_rs2_data := MuxLookup(io.control.dec_rs2_sel, regfile_rs2_data, Array(
      RS2_EXE -> exe_rd_data,
      RS2_MEM -> mem_rd_data,
      RS2_WB -> wb_rd_data //,
      //RS2_DEC -> regfile_rs2_data //FIXME: causes chisel verilog bug
    ))
  } else {
    dec_rs1_data := regfile_rs1_data
    dec_rs2_data := regfile_rs2_data
  }

  // Generate immediate values.
  val dec_imm_i = Cat(Fill(21, dec_reg_inst(31)), dec_reg_inst(30, 20))
  val dec_imm_s = Cat(Fill(21, dec_reg_inst(31)), dec_reg_inst(30, 25), dec_reg_inst(11, 7))
  val dec_imm_b = Cat(Fill(20, dec_reg_inst(31)), dec_reg_inst(7), dec_reg_inst(30, 25), dec_reg_inst(11, 8), 0.U(1.W))
  val dec_imm_u = Cat(dec_reg_inst(31, 12), 0.U(12.W))
  val dec_imm_j = Cat(Fill(12, dec_reg_inst(31)), dec_reg_inst(19, 12), dec_reg_inst(20), dec_reg_inst(30, 21), 0.U(1.W))
  // For CSR
  val dec_imm_z = Cat(0.U(27.W), dec_reg_inst(19, 15))

  val dec_imm = MuxLookup(io.control.dec_imm_sel, dec_imm_i, Array(
    IMM_S -> dec_imm_s,
    IMM_B -> dec_imm_b,
    IMM_U -> dec_imm_u,
    IMM_J -> dec_imm_j,
    IMM_I -> dec_imm_i,
    IMM_Z -> dec_imm_z
  ))

  // Set operands for ALU.
  val dec_op1 = MuxLookup(io.control.dec_op1_sel, 0.U(32.W), Array(
    OP1_RS1 -> dec_rs1_data,
    OP1_PC -> dec_reg_pc
  )) // default: OP1_0
  val dec_op2 = MuxLookup(io.control.dec_op2_sel, 0.U(32.W), Array(
    OP2_RS2 -> dec_rs2_data,
    OP2_IMM -> dec_imm
  )) // default: OP2_0

  val dec_csr_data = Mux(io.control.dec_op2_sel === OP2_IMM, dec_imm, dec_rs1_data)

  // Provide data to control.
  io.control.dec_tid := dec_reg_tid
  io.control.dec_inst := dec_reg_inst


  // Provide inputs to execute stage registers.
  exe_reg_tid := dec_reg_tid
  exe_reg_rd_addr := dec_reg_inst(11, 7)
  exe_reg_op1 := dec_op1
  exe_reg_op2 := dec_op2
  exe_reg_rs1_data := dec_rs1_data
  exe_reg_rs2_data := dec_rs2_data
  exe_reg_pc := dec_reg_pc
  exe_reg_pc4 := dec_reg_pc4
  exe_reg_csr_addr := dec_reg_inst(31, 20)
  exe_reg_csr_data := dec_csr_data


  // ************************************************************
  // Execute Stage

  // ALU
  val alu = Module(new ALU)
  alu.io.op1 := exe_reg_op1
  alu.io.op2 := exe_reg_op2
  alu.io.shift := exe_reg_op2(4, 0)
  alu.io.func := io.control.exe_alu_type
  exe_alu_result := alu.io.result
  // ALU is used to calculate address for L*, S*, J*, B*
  exe_address := exe_alu_result

  // Check branch condition.
  val exe_br_cond = Wire(Bool())
  val exe_lt = exe_reg_rs1_data.asSInt < exe_reg_rs2_data.asSInt
  val exe_ltu = exe_reg_rs1_data < exe_reg_rs2_data
  val exe_eq = exe_reg_rs1_data === exe_reg_rs2_data
  val def_exe_br_cond = false.B
  exe_br_cond := MuxLookup(io.control.exe_br_type, def_exe_br_cond, Array(
    BR_EQ -> exe_eq,
    BR_LT -> exe_lt,
    BR_LTU -> exe_ltu,
    BR_NE -> !exe_eq,
    BR_GE -> !exe_lt,
    BR_GEU -> !exe_ltu
  ))

  // Multiplier
  val mem_mul_result = WireInit(mem_reg_rd_data)
  if (conf.mul) {
    val mult = Module(new Multiplier())
    mult.io.op1 := exe_reg_op1
    mult.io.op2 := exe_reg_op2
    mult.io.func := io.control.exe_mul_type
    mem_mul_result := mult.io.result
  }

  // Load and Store Unit
  // Request in execute stage, response in memory stage.
  val loadstore = Module(new LoadStore())
  // memories and bus
  loadstore.io.dmem <> io.dmem
  loadstore.io.imem.r <> DontCare // loadstore only uses write port
  loadstore.io.imem.rw <> io.imem.rw
  loadstore.io.bus <> io.bus
  // datapath inputs
  loadstore.io.addr := exe_address
  loadstore.io.thread := exe_reg_tid
  loadstore.io.load := io.control.exe_load
  loadstore.io.store := io.control.exe_store
  loadstore.io.mem_type := io.control.exe_mem_type
  loadstore.io.data_in := exe_reg_rs2_data
  // control inputs
  loadstore.io.kill := io.control.exe_kill

  // Debug signals
  io.imem_store := loadstore.io.imem_store

  // Control and Status Register (CSR) Unit
  val csr = Module(new CSR(confHash, conf))
  val exe_csr_data = if (conf.dedicatedCsrData) exe_reg_csr_data else exe_alu_result
  // CSR modification
  csr.io.rw.addr := exe_reg_csr_addr
  csr.io.rw.thread := exe_reg_tid
  csr.io.rw.csr_type := io.control.exe_csr_type
  csr.io.rw.write := io.control.exe_csr_write
  csr.io.rw.data_in := exe_csr_data
  csr.io.rw.valid := io.control.exe_valid

  // exception handling
  csr.io.kill := io.control.exe_kill
  csr.io.exception := io.control.exe_exception
  csr.io.epc := exe_reg_pc
  csr.io.cause := io.control.exe_cause

  // timing instructions
  csr.io.sleep_du := io.control.exe_sleep_du
  csr.io.sleep_wu := io.control.exe_sleep_wu

  csr.io.ie := io.control.exe_ie
  csr.io.ee := io.control.exe_ee
  io.control.exe_expire_du := csr.io.expire_du
  io.control.exe_expire_wu := csr.io.expire_wu
  io.control.exe_expire_ie := csr.io.expire_ie
  io.control.exe_expire_ee := csr.io.expire_ee
  io.control.timer_expire_du_wu := csr.io.timer_expire_du_wu

  csr.io.if_tid := if_reg_tid
  csr.io.dec_tid := dec_reg_tid

  // privileged
  csr.io.mret := io.control.exe_mret

  // external interrupt (per thread)
  csr.io.int_exts := io.int_exts

  // stats (not designed for performance)
  csr.io.cycle := io.control.exe_cycle
  csr.io.instret := io.control.exe_instret

  // trap handling address, depends on conf.regEvec
  exe_evec := csr.io.evecs(exe_reg_tid)
  exe_mepc  := csr.io.mepcs(exe_reg_tid)

  // memory protection
  loadstore.io.dmem_protection := csr.io.dmem_protection
  loadstore.io.imem_protection := csr.io.imem_protection


  // Only keep needed result for rd.
  exe_rd_data := Mux(io.control.exe_rd_data_sel === EXE_RD_CSR, csr.io.rw.data_out,
    Mux(io.control.exe_rd_data_sel === EXE_RD_PC4, exe_reg_pc4,
      exe_alu_result)) // default: EXE_RD_ALU

  // Provide data to control.
  io.control.exe_br_cond := exe_br_cond
  io.control.exe_tid := exe_reg_tid
  io.control.exe_rd_addr := exe_reg_rd_addr

  // exceptions from execute stage to control
  io.control.exe_int_ext := csr.io.int_ext
  io.control.exe_exc_priv_inst := csr.io.priv_fault
  io.control.exe_exc_load_misaligned := loadstore.io.load_misaligned
  io.control.exe_exc_load_fault := loadstore.io.load_fault
  io.control.exe_exc_store_misaligned := loadstore.io.store_misaligned
  io.control.exe_exc_store_fault := loadstore.io.store_fault

  // Provide inputs to memory stage registers.
  mem_reg_tid := exe_reg_tid
  mem_reg_rd_addr := exe_reg_rd_addr
  mem_reg_rd_data := exe_rd_data
  mem_reg_address := exe_address

  // ************************************************************
  // Memory Stage

  // Data to store back to rd can come from execute stage or data memory.
  mem_rd_data :=
    Mux(io.control.mem_rd_data_sel === MEM_RD_MEM, loadstore.io.data_out,
      Mux(io.control.mem_rd_data_sel === MEM_RD_MUL, mem_mul_result, //mul
        // MEM_RD_REG
        mem_reg_rd_data)
    ) //mul

  // Provide inputs to rd port of register file.
  regfile.io.write(0).thread := mem_reg_tid
  regfile.io.write(0).addr := mem_reg_rd_addr
  regfile.io.write(0).data := mem_rd_data
  regfile.io.write(0).enable := io.control.mem_rd_write

  io.control.mem_tid := mem_reg_tid
  io.control.mem_rd_addr := mem_reg_rd_addr

  // thread scheduling
  io.control.csr_slots := csr.io.slots
  io.control.csr_tmodes := csr.io.tmodes

  // I/O
  for (tid <- 0 until conf.threads) {
    io.host.to_host(tid) := csr.io.host.to_host(tid)
  }
  io.gpio <> csr.io.gpio


  // trap handling address, depends on conf.regEvec
  mem_evec := csr.io.evecs(mem_reg_tid)
  mem_mepc := csr.io.mepcs(mem_reg_tid)

  wb_reg_tid := mem_reg_tid
  wb_reg_rd_addr := mem_reg_rd_addr
  wb_reg_rd_data := mem_rd_data

  // ************************************************************
  // Writeback Stage
  wb_rd_data := wb_reg_rd_data

  io.control.wb_tid := wb_reg_tid
  io.control.wb_rd_addr := wb_reg_rd_addr

}
