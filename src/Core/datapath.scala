/******************************************************************************
datapath.scala:
  Datapath.
Authors: 
  Michael Zimmer (mzimmer@eecs.berkeley.edu)
  Chris Shaver (shaver@eecs.berkeley.edu)
  Hokeun Kim (hokeunkim@eecs.berkeley.edu)
Acknowledgement:
  Based on Sodor single-thread 5-stage RISC-V processor by Christopher Celio.
  https://github.com/ucb-bar/riscv-sodor/
******************************************************************************/

package Core
{

import Chisel._
import Node._
import Common._
import CoreConstants._

class DatToCtlIo(conf: CoreConfig) extends Bundle()
{
  val if_valid    = Bool(OUTPUT)
  val if_tid      = UInt(OUTPUT, conf.threadBits)
  val dec_valid   = Bool(OUTPUT)
  val dec_inst    = Bits(OUTPUT, 32)
  val dec_tid     = UInt(OUTPUT, conf.threadBits)
  val exe_valid   = Bool(OUTPUT)
  val exe_tid     = UInt(OUTPUT, conf.threadBits)
  val exe_br_eq   = Bool(OUTPUT)
  val exe_br_lt   = Bool(OUTPUT)
  val exe_br_ltu  = Bool(OUTPUT)
  val exe_br_type = UInt(OUTPUT,  4)
  val exe_schedule = Bits(OUTPUT, 32) 
  val exe_thread_modes = Vec.fill(conf.threads) { UInt(OUTPUT, 2) }
  //val exe_du_wait = Bool(OUTPUT) //ifdu
  val exe_exception = Vec.fill(conf.threads) { Bool(OUTPUT) } //ifex
  val exe_ie_en = Vec.fill(conf.threads) { Bool(OUTPUT) } //ifex
}

class DatapathIo(conf: CoreConfig) extends Bundle()
{
  val ispm = new MemIo(conf.iSpmAddrBits).flip() //TODO: selective list
  val dspm = new MemIo(conf.dSpmAddrBits).flip()
  val ctl  = new CtlToDatIo(conf).flip()
  val dat  = new DatToCtlIo(conf)
  val top  = new CoreIo(conf.iSpmAddrBits)
}

class Datapath(conf: CoreConfig) extends Module 
{
  val io = new DatapathIo(conf)

  //**********************************
  // Pipeline State Registers

  // Instruction Fetch State
  val if_reg_pcs            = Vec.fill(conf.threads){ Reg(init = PC_INIT.toUInt) } // PC for each thread. //TODO force to 30 bits?
  val if_reg_tid            = Reg(outType= UInt() )
  val if_reg_valid          = Reg(init = Bool(false)) // Used to kill cycle.

  // Instruction Decode State
  val dec_reg_inst          = Reg(init = BUBBLE)
  val dec_reg_pc            = Reg(outType= UInt() )
  val dec_reg_tid           = Reg(outType= UInt() )
  val dec_reg_valid         = Reg(init = Bool(false))

  // Execute State
  val exe_reg_pc            = Reg(outType= UInt() ) // Used for relative jump and return address.
  val exe_reg_tid           = Reg(outType= UInt() )
  val exe_reg_valid         = Reg(init = Bool(false))
  val exe_reg_wbaddr        = Reg(outType= UInt() ) // rd or ra.
  val exe_reg_rs1_addr      = Reg(outType= UInt() ) // Address still used for PCR.
  val exe_reg_rs1_data      = Reg(outType= Bits() )
  val exe_reg_op2_data      = Reg(outType= Bits() ) // Either rs2 or sign-extended immediate.  
  val exe_reg_rs2_data      = Reg(outType= Bits() )
  val exe_reg_ctrl_br_type  = Reg(init = BR_N) // Branch condition.
  val exe_reg_ctrl_alu_fun  = Reg(outType= UInt() )
  val exe_reg_ctrl_wb_sel   = Reg(outType= UInt() ) // Source of data for rd.
  val exe_reg_ctrl_rf_wen   = Reg(init = Bool(false)) // Write enable for regfile.
  val exe_reg_ctrl_mem_r    = Reg(init = Bool(false))
  val exe_reg_ctrl_mem_w    = Reg(init = Bool(false))
  val exe_reg_ctrl_mem_mask = Reg(outType= UInt() )
  val exe_reg_ctrl_pcr_fcn  = Reg(init = PCR_N) // PCR op.
  //val exe_reg_ns_clock      = Reg(init = UInt(0, 64))  //ifget
  val exe_reg_ns_clock      = if(conf.getTime) { 
 //                               Reg(init = Bits("h1FFFFFE0C", 64).toUInt) 
                                Reg(init = Bits(0, 64).toUInt) 
                              } else { null }// 50 cycles until h toggle. //ifgt
  val exe_reg_store         = if(conf.getTime) {
                                Vec.fill(conf.threads) { Reg(init = UInt(0, 32)) } // Data storage for multicycle instructions. //ifgt
                              } else { null }
  val exe_reg_ie_en         = if(conf.exceptionOnExpire) { 
                                Vec.fill(conf.threads) { Reg(init = Bool(false)) } // ifee
                              } else { null }
  val exe_reg_ie_ns         = if(conf.exceptionOnExpire) { 
                                Vec.fill(conf.threads) { Reg(init = UInt(0, 64)) } // ifee
                              } else { null }
  val exe_reg_du_en         = if(conf.delayUntil) { 
                                Vec.fill(conf.threads) { Reg(init = Bool(false)) } // ifee
                              } else { null }
  val exe_reg_du_ns         = if(conf.delayUntil) { 
                                Vec.fill(conf.threads) { Reg(init = UInt(0, 64)) } // ifee
                              } else { null }
                            
                              // TEMP HACK
                              //for(tid <- 0 until conf.threads) {
                              //  exe_reg_ie_en(tid) := exe_reg_ie_en(tid)
                              //  exe_reg_ie_ns(tid) := exe_reg_ie_ns(tid)
                              //}

  // Memory State
  val mem_reg_tid           = Reg(outType= UInt() )
  val mem_reg_alu_out       = Reg(outType= Bits() )
  val mem_reg_wbaddr        = Reg(outType= UInt() )
  val mem_reg_ctrl_rf_wen   = Reg(init = Bool(false))
  val mem_reg_ctrl_mem_mask = Reg(outType= UInt() )
  val mem_reg_ctrl_wb_sel   = Reg(outType= UInt() )
  val mem_reg_addr_dest     = Reg(outType= UInt() )

  // Writeback State
  val wb_reg_tid            = Reg(outType= UInt() )
  val wb_reg_wbaddr         = Reg(outType= UInt() )
  val wb_reg_wbdata         = Reg(outType= Bits(width = XPRLEN) )
  val wb_reg_ctrl_rf_wen    = Reg(init = Bool(false))


  //**********************************
  // Prepare for instruction fetch stage.
  
  val if_pc_plus4 = UInt()
  val exe_brjmp_target = UInt()
  val exe_evec = Vec.fill(conf.threads) { UInt() } //ifex

  // TODO bundle
  val exe_mem_dest = UInt()
  val exe_mem_addr = UInt()
  val exe_mem_wdata = Bits()
  val exe_mem_w = Bool()
  
  // Source of next PC for all PC registers.
  val next_if_reg_pcs = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) {
    next_if_reg_pcs(tid) := 
        Mux(io.ctl.next_pc_sel(tid) === NPC_PCREG, if_reg_pcs(tid),
        Mux(io.ctl.next_pc_sel(tid) === NPC_PLUS4, if_pc_plus4,
        Mux(io.ctl.next_pc_sel(tid) === NPC_BRJMP, exe_brjmp_target,
        Mux(io.ctl.next_pc_sel(tid) === NPC_EVEC,
        if(conf.exceptions) { exe_evec(tid) } else { if_reg_pcs(tid) }, //ifex
        Mux(io.ctl.next_pc_sel(tid) === NPC_DEC, 
        if(conf.mulStages == 3) { dec_reg_pc(tid) } else { if_reg_pcs(tid) }, //ifmul3
        if_reg_pcs(tid))))))
  }
 
  // Next PC to be fetched.
  val next_pc = next_if_reg_pcs(io.ctl.next_tid)

  // Instruction Memory
  // Address needs to be provided to SRAM I-SPM at end of cycle before fetch stage.
  // Temporarily allow ld/st from ISPM
  // Note: Memory and threads not protected (other threads may lose their cycle)
  val ispm_w = Mux(exe_mem_dest === ADDR_DEST_ISPM, exe_mem_w, Bool(false))
  io.ispm.req.addr := Mux(exe_mem_dest != ADDR_DEST_ISPM, 
                          next_pc(conf.iSpmAddrBits+1,2),
                          exe_mem_addr(conf.iSpmAddrBits+1,2)) 
  io.ispm.req.wdata := exe_mem_wdata
  io.ispm.req.w := ispm_w
  io.ispm.req.r := !ispm_w
  
  //TODO exception if PC out of range.
  //val dest_ispm = (next_pc(XPRLEN-1, XPRLEN-ADDR_ISPM_BITS) ^ ADDR_ISPM_VAL) === Bits(0, ADDR_ISPM_BITS) 
    //bug io.dat.exe_exception(tid) := Bool(false)
  for(tid <- 0 until conf.threads) {
    io.dat.exe_exception(tid) := Bool(false)
  }
  // TODO FIXME: hack to prevent chisel bug
  when(if_reg_pcs(if_reg_tid) === Bits("h00000000").toUInt) {
    io.dat.exe_exception(if_reg_tid) := Bool(true)
  }

  if_reg_pcs := next_if_reg_pcs
  if_reg_tid := io.ctl.next_tid
  // Kill cycle if scheduler doesn't return a valid result or 
  // instruction memory is being written to.
  if_reg_valid := io.ctl.next_valid && (exe_mem_dest != ADDR_DEST_ISPM)
  //val next_valid = io.ctl.next_valid

  //**********************************
  // Instruction Fetch Stage
  
  // PC+4 of fetched thread.
  if_pc_plus4 := if_reg_pcs(if_reg_tid) + UInt(4, XPRLEN)
 
  // On load-use with 1 thread scheduled, decode instruction must be replayed.
  val next_dec_inst = Bits()
  next_dec_inst := dec_reg_inst
  when(!io.ctl.dec_stall) {
    next_dec_inst := Mux(io.ctl.if_kill || !if_reg_valid, BUBBLE, io.ispm.resp.data)
    dec_reg_pc := if_reg_pcs(if_reg_tid)
    dec_reg_tid := if_reg_tid
    dec_reg_valid := if_reg_valid && !io.ctl.if_kill 
  }
  dec_reg_inst := next_dec_inst

  // Register file read addresses need to be provided to 
  // SRAM at end of cycle before decode stage.
  val if_rs1_addr = next_dec_inst(26, 22).toUInt
  val if_rs2_addr = next_dec_inst(21, 17).toUInt
  val if_tid = Mux(io.ctl.dec_stall, dec_reg_tid, if_reg_tid)

  //**********************************
  // Decode Stage

  val dec_rs1_addr = dec_reg_inst(26, 22).toUInt
  val dec_rs2_addr = dec_reg_inst(21, 17).toUInt
  val dec_wbaddr   = Mux(io.ctl.wa_sel != WA_RA, dec_reg_inst(31, 27).toUInt, RA)
  val mem_wbdata   = Bits(width = XPRLEN)

  // Register File
  // Read from end of fetch stage, Write from end of memory stage.
  // TODO: dont need r0
  val regfile = Module(new RegisterFile(conf.threads*32, 5+conf.threadBits))
  regfile.io.rs1_addr := Cat(if_tid, if_rs1_addr)
  regfile.io.rs2_addr := Cat(if_tid, if_rs2_addr)
  regfile.io.waddr    := Cat(mem_reg_tid, mem_reg_wbaddr)
  regfile.io.wdata    := mem_wbdata
  regfile.io.wen      := mem_reg_ctrl_rf_wen

  
  val rs1NZ = dec_rs1_addr != UInt(0);
  val rs2NZ = dec_rs2_addr != UInt(0);
  val rf_rs1_data = Mux(rs1NZ, regfile.io.rs1_data, UInt(0, XPRLEN))
  val rf_rs2_data = Mux(rs2NZ, regfile.io.rs2_data, UInt(0, XPRLEN))

  // immediates
  val imm_btype = Cat(dec_reg_inst(31,27), dec_reg_inst(16,10))
  val imm_itype = dec_reg_inst(21,10)
  val imm_ltype = dec_reg_inst(26,7)
  val imm_jtype = dec_reg_inst(31,7)

  // sign-extend immediates
  val imm_itype_sext = Cat(Fill(imm_itype(11), 20), imm_itype)
  val imm_btype_sext = Cat(Fill(imm_btype(11), 20), imm_btype)
  val imm_jtype_sext = Cat(Fill(imm_jtype(24),  7), imm_jtype)

  // Operand 2 Mux   
  val dec_alu_op2 = MuxCase(UInt(0), Array(
               (io.ctl.op2_sel === OP2_RS2)   -> rf_rs2_data,
               (io.ctl.op2_sel === OP2_ITYPE) -> imm_itype_sext,
               (io.ctl.op2_sel === OP2_BTYPE) -> imm_btype_sext,
               (io.ctl.op2_sel === OP2_LTYPE) -> Cat(imm_ltype, Bits(0, 12)),
               (io.ctl.op2_sel === OP2_JTYPE) -> imm_jtype_sext
               )).toUInt

  // Bypass Muxes
  val exe_alu_out  = Bits(width = XPRLEN)

  val dec_rs1_data = Bits(width = XPRLEN)
  val dec_op2_data = Bits(width = XPRLEN)
  val dec_rs2_data = Bits(width = XPRLEN)

  val op2Rs = io.ctl.op2_sel === OP2_RS2

  // TODO: optimize for 2-3 fixed threads.
  if(conf.flex || conf.threads < 4) {
    dec_rs1_data := MuxCase(rf_rs1_data, Array(
      ((exe_reg_tid === dec_reg_tid) && (exe_reg_wbaddr === dec_rs1_addr) && rs1NZ && exe_reg_ctrl_rf_wen) -> exe_alu_out,
      ((mem_reg_tid === dec_reg_tid) && (mem_reg_wbaddr === dec_rs1_addr) && rs1NZ && mem_reg_ctrl_rf_wen) -> mem_wbdata,
      ((wb_reg_tid === dec_reg_tid) && (wb_reg_wbaddr  === dec_rs1_addr) && rs1NZ &&  wb_reg_ctrl_rf_wen) -> wb_reg_wbdata
    ));

    dec_op2_data := MuxCase(dec_alu_op2, Array(
      ((exe_reg_tid === dec_reg_tid) && (exe_reg_wbaddr === dec_rs2_addr) && rs2NZ && exe_reg_ctrl_rf_wen && op2Rs) -> exe_alu_out,
      ((mem_reg_tid === dec_reg_tid) && (mem_reg_wbaddr === dec_rs2_addr) && rs2NZ && mem_reg_ctrl_rf_wen && op2Rs) -> mem_wbdata,
      ((wb_reg_tid === dec_reg_tid) && (wb_reg_wbaddr  === dec_rs2_addr) && rs2NZ &&  wb_reg_ctrl_rf_wen && op2Rs) -> wb_reg_wbdata
    ));

    dec_rs2_data := MuxCase(rf_rs2_data, Array(
      ((exe_reg_tid === dec_reg_tid) && (exe_reg_wbaddr === dec_rs2_addr) && rs2NZ && exe_reg_ctrl_rf_wen) -> exe_alu_out,
      ((mem_reg_tid === dec_reg_tid) && (mem_reg_wbaddr === dec_rs2_addr) && rs2NZ && mem_reg_ctrl_rf_wen) -> mem_wbdata,
      ((wb_reg_tid === dec_reg_tid) && (wb_reg_wbaddr  === dec_rs2_addr) && rs2NZ &&  wb_reg_ctrl_rf_wen) -> wb_reg_wbdata
    ));
  } else {
    dec_rs1_data := rf_rs1_data
    dec_op2_data := dec_alu_op2
    dec_rs2_data := rf_rs2_data
  }


  // Interrupt on expire.  //ifee
  if(conf.exceptionOnExpire) {
    when(io.ctl.ie_enable) {
      exe_reg_ie_en(dec_reg_tid) := Bool(true)
      exe_reg_ie_ns(dec_reg_tid) := Cat(dec_rs1_data, dec_rs2_data).toUInt
    }
    when(io.ctl.ie_disable) {
      exe_reg_ie_en(dec_reg_tid) := Bool(false)
    }
    // TODO: verify.
    io.dat.exe_ie_en := exe_reg_ie_en
  }

  if(conf.delayUntil) {
    when(io.ctl.du_enable) {
      exe_reg_du_en(dec_reg_tid) := Bool(true)
      exe_reg_du_ns(dec_reg_tid) := Cat(dec_rs1_data, dec_rs2_data).toUInt
    }
    for(tid <- 0 until conf.threads) {
      when(io.dat.exe_exception(tid)) {
        exe_reg_du_en(tid) := Bool(false)
      }
    }
  }
  
   exe_reg_pc            := dec_reg_pc
   exe_reg_tid           := dec_reg_tid
   exe_reg_valid         := dec_reg_valid
   exe_reg_wbaddr        := dec_wbaddr
   exe_reg_rs1_addr      := dec_rs1_addr
   exe_reg_rs1_data      := dec_rs1_data
   exe_reg_op2_data      := dec_op2_data
   exe_reg_rs2_data      := dec_rs2_data
   exe_reg_ctrl_br_type  := io.ctl.br_type
   exe_reg_ctrl_alu_fun  := io.ctl.alu_fun
   exe_reg_ctrl_wb_sel   := io.ctl.wb_sel
   exe_reg_ctrl_rf_wen   := io.ctl.rf_wen
   exe_reg_ctrl_mem_r    := io.ctl.mem_r
   exe_reg_ctrl_mem_w    := io.ctl.mem_w
   exe_reg_ctrl_mem_mask := io.ctl.mem_mask
   exe_reg_ctrl_pcr_fcn  := io.ctl.pcr_fcn

   when(io.ctl.dec_kill || io.ctl.dec_stall) {
      exe_reg_valid         := Bool(false)
      exe_reg_wbaddr        := UInt(0)
      exe_reg_ctrl_rf_wen   := Bool(false)
      exe_reg_ctrl_mem_r    := Bool(false)
      exe_reg_ctrl_mem_w    := Bool(false)
      exe_reg_ctrl_pcr_fcn  := PCR_N
      exe_reg_ctrl_br_type  := BR_N
    }

  //**********************************
  // Execute Stage
  
  val pcr_out = Bits(width = XPRLEN)

  // Alu
  val alu = Module(new Alu(conf))
  alu.io.op1  := exe_reg_rs1_data
  alu.io.op2  := exe_reg_op2_data
  alu.io.func := exe_reg_ctrl_alu_fun
 
  // Multiplier
  val mul = Module(new Multiplier(conf.mulStages))
  mul.io.op1 := exe_reg_rs1_data
  mul.io.op2 := exe_reg_op2_data
  mul.io.func := exe_reg_ctrl_alu_fun
  //mul.io.valid := exe_reg_ctrl

  // Real-time clock //ifgt
  if(conf.getTime) {
    exe_reg_ns_clock := exe_reg_ns_clock + UInt(10, 64)
    // When GT_L (get lower 32 bits of ns) is executed, store upper 32 bits
    // of ns to allow GT_L, GT_H to be atomic clock read.
    when(exe_reg_ctrl_wb_sel === WB_GTL) {
      exe_reg_store(exe_reg_tid) := exe_reg_ns_clock(63, 32)
    }
  }

  val exe_du_expire = Vec.fill(conf.threads) { Bool() } //ifdu
  // Interrupt on expire.  //ifee
  for(tid <- 0 until conf.threads) {
    //bug io.dat.exe_exception(tid) := Bool(false)
    if(conf.exceptionOnExpire) {
      when(exe_reg_ie_en(tid)) {
        when(exe_reg_ns_clock >= exe_reg_ie_ns(tid)) {
          io.dat.exe_exception(tid) := Bool(true)
          exe_reg_ie_en(tid) := Bool(false)
        }
      }
    }
    exe_du_expire(tid) := Bool(false)
    if(conf.delayUntil) {
      when(exe_reg_du_en(tid)) {
        when(exe_reg_ns_clock >= exe_reg_du_ns(tid)) {
          exe_du_expire(tid) := Bool(true)
          exe_reg_du_en(tid) := Bool(false)
        }
      }
    }
  }

  // Compare current clock to delay until time. 
  //val exe_du_wait = Bool() //ifdu
  //if(conf.delayUntil) {
  //  exe_du_wait :=  exe_reg_ns_clock < Cat(exe_reg_rs1_data, exe_reg_rs2_data).toUInt //ifdu
  //} else {
  //  exe_du_wait := Bool(false)
  //}
  val exe_pc_plus4 = (exe_reg_pc + UInt(4))(XPRLEN-1,0);

  exe_alu_out := Mux(exe_reg_ctrl_wb_sel === WB_PC4, exe_pc_plus4,
                 Mux(exe_reg_ctrl_wb_sel === WB_PCR, pcr_out,
                 Mux(exe_reg_ctrl_wb_sel === WB_MUL, 
                       if(conf.mulStages == 1) { mul.io.result } else { alu.io.result },
                 Mux(exe_reg_ctrl_wb_sel === WB_GTL, 
                       if(conf.getTime) { exe_reg_ns_clock(31, 0) } else { alu.io.result }, //ifgt
                 Mux(exe_reg_ctrl_wb_sel === WB_GTH, 
                       if(conf.getTime) { exe_reg_store(exe_reg_tid) } else {alu.io.result}, //ifgt
                 alu.io.result)))))


  // Branch/Jump Target Calculation
  val brjmp_offset = exe_reg_pc + Cat(exe_reg_op2_data(XPRLEN-1,0), UInt(0,1)).toUInt
  val jmp_absolute = alu.io.result.toUInt
  // Jump/Branch target from execute stage.
  exe_brjmp_target := Mux(io.ctl.exe_pc_sel === PC_BRJMP, brjmp_offset, 
                      //Mux(io.ctl.exe_pc_sel === PC_DU, if(conf.delayUntil) { exe_reg_pc } else { jmp_absolute }, //ifdu
                      jmp_absolute)//)

  // Address in range and memory operation.
  val exe_mem_en = (exe_reg_ctrl_mem_w || exe_reg_ctrl_mem_r)
  exe_mem_dest := MuxCase(ADDR_DEST_NONE, Array(
    ((alu.io.result(XPRLEN-1, XPRLEN-ADDR_DSPM_BITS) ^ ADDR_DSPM_VAL) === Bits(0, ADDR_DSPM_BITS) && exe_mem_en) -> ADDR_DEST_DSPM,
    ((alu.io.result(XPRLEN-1, XPRLEN-ADDR_ISPM_BITS) ^ ADDR_ISPM_VAL) === Bits(0, ADDR_ISPM_BITS) && exe_mem_en) -> ADDR_DEST_ISPM,
    (exe_mem_en) -> ADDR_DEST_PERIF))

  // TODO: update
  // Temporary: Hook up I-SPM
  exe_mem_addr := alu.io.result.toUInt
  exe_mem_wdata := exe_reg_rs2_data
  exe_mem_w := exe_reg_ctrl_mem_w 
  // Address and data needs to be provided to SRAM D-SPM at end of execute stage and not in memory stage.
  // Alignment and mask generation for subword and word writes.
  val exe_store_handler = Module(new StoreHandler())
  exe_store_handler.io.addr := alu.io.result(1, 0).toUInt
  exe_store_handler.io.din  := exe_reg_rs2_data
  exe_store_handler.io.typ  := exe_reg_ctrl_mem_mask

  val exe_mem_page = alu.io.result(conf.dSpmPageIndex+conf.dSpmPageBits-1,conf.dSpmPageIndex).toUInt
  val exe_mem_valid = Bool()
  io.dspm.req.addr      := alu.io.result(conf.dSpmAddrBits+1,2).toUInt
  io.dspm.req.r        := exe_reg_ctrl_mem_r && (exe_mem_dest === ADDR_DEST_DSPM)
  io.dspm.req.w        := exe_reg_ctrl_mem_w && (exe_mem_dest === ADDR_DEST_DSPM) && exe_mem_valid
  io.dspm.req.wmask     := exe_store_handler.io.mask 
  io.dspm.req.wdata     := exe_store_handler.io.dout

  // Connect to peripherals
  io.top.bus.req.addr := Reg(next = alu.io.result.toUInt)
  io.top.bus.req.wdata := Reg(next = exe_reg_rs2_data)
  io.top.bus.req.r := Reg(next = (exe_mem_dest === ADDR_DEST_PERIF) && exe_reg_ctrl_mem_r)
  io.top.bus.req.w := Reg(next = (exe_mem_dest === ADDR_DEST_PERIF) && exe_reg_ctrl_mem_w)
  
  // Co-processor Registers
  val pcr = Module(new Pcr(conf))
  pcr.io.host <> io.top.host
  io.dat.exe_schedule := pcr.io.schedule 
  io.dat.exe_thread_modes := pcr.io.thread_modes
  // MTPCR: in dec, read reg(rs2); in wb, write pcr(rs1) and reg(rd=0)
  // MFPCR: in dec, read pcr(rs1); in wb, write reg(rd)
  pcr.io.fcn       := exe_reg_ctrl_pcr_fcn
  pcr.io.req_addr  := exe_reg_rs1_addr
  pcr.io.req_tid   := exe_reg_tid
  pcr.io.req_wdata := exe_reg_rs2_data
  if(conf.stats) {
    val cvalid = Reg(next = Reg(next = Reg(next = io.ctl.next_valid)))
    pcr.io.stat.ivalid := cvalid && exe_reg_valid
    pcr.io.stat.cvalid := cvalid
    pcr.io.stat.tid := exe_reg_tid 
  }
  pcr_out          := pcr.io.resp_data
  pcr.io.tsleep := io.ctl.tsleep
  pcr.io.tsleep_tid := dec_reg_tid

  //TODO: allow region to be size 0
  exe_mem_valid := (exe_mem_page <= pcr.io.mem_shared) || (exe_mem_page >= pcr.io.mem_priv_l(exe_reg_tid) && exe_mem_page <= pcr.io.mem_priv_h(exe_reg_tid))

  for(tid <- 0 until conf.threads) {
    pcr.io.exception(tid) := io.dat.exe_exception(tid) || exe_du_expire(tid)
  }
  //pcr.io.exception := io.dat.exe_exception || //ifex
  if(conf.exceptions) {
    for(tid <- 0 until conf.threads) {
      exe_evec(tid) := pcr.io.evec(tid).toUInt
      pcr.io.epc(tid) := MuxCase(if_reg_pcs(tid), Array(
        (io.ctl.next_epc(tid) === EPC_PCREG) -> if_reg_pcs(tid),
        (io.ctl.next_epc(tid) === EPC_IFPC) -> if_reg_pcs(if_reg_tid),
        (io.ctl.next_epc(tid) === EPC_DECPC) -> dec_reg_pc,
        (io.ctl.next_epc(tid) === EPC_BRJMP) -> exe_brjmp_target
      ))
    }
  }

  mem_reg_tid           := exe_reg_tid 
  mem_reg_alu_out       := exe_alu_out
  mem_reg_wbaddr        := exe_reg_wbaddr
  mem_reg_ctrl_rf_wen   := exe_reg_ctrl_rf_wen
  mem_reg_ctrl_mem_mask := exe_reg_ctrl_mem_mask
  mem_reg_ctrl_wb_sel   := exe_reg_ctrl_wb_sel
  mem_reg_addr_dest     := exe_mem_dest


  //**********************************
  // Memory Stage


  // TODO: subword ld/st w/ perif and ispm?

  // Alignment and sign-extension for subword reads. 
  val mem_load_handler = Module(new LoadHandler())
  mem_load_handler.io.addr := mem_reg_alu_out(1, 0).toUInt
  mem_load_handler.io.din  := Mux(mem_reg_addr_dest === ADDR_DEST_PERIF, io.top.bus.resp.data, io.dspm.resp.data)
  mem_load_handler.io.typ  := mem_reg_ctrl_mem_mask
  //val mem_resp_data = mem_load_handler.io.dout
  val mem_resp_data = MuxCase(mem_load_handler.io.dout, Array(
    (mem_reg_addr_dest === ADDR_DEST_DSPM) -> mem_load_handler.io.dout,
    (mem_reg_addr_dest === ADDR_DEST_ISPM) -> io.ispm.resp.data,
    (mem_reg_addr_dest === ADDR_DEST_PERIF) -> mem_load_handler.io.dout))
    //(mem_reg_addr_dest === ADDR_DEST_PERIF) -> io.top.perif.resp_data))

  // WB Mux
  mem_wbdata := MuxCase(mem_reg_alu_out, Array(
    (mem_reg_ctrl_wb_sel === WB_ALU) -> mem_reg_alu_out,
    (mem_reg_ctrl_wb_sel === WB_PC4) -> mem_reg_alu_out,
    (mem_reg_ctrl_wb_sel === WB_MEM) -> mem_resp_data,
    (mem_reg_ctrl_wb_sel === WB_MUL) -> 
    (if(conf.mulStages >= 2) { mul.io.result } else { mem_reg_alu_out }),
    (mem_reg_ctrl_wb_sel === WB_PCR) -> mem_reg_alu_out,
    (mem_reg_ctrl_wb_sel === WB_GTL) -> mem_reg_alu_out, 
    (mem_reg_ctrl_wb_sel === WB_GTH) -> mem_reg_alu_out
  )).toSInt()


  //**********************************
  // Writeback Stage
 
  wb_reg_tid            := mem_reg_tid
  wb_reg_wbaddr         := mem_reg_wbaddr
  wb_reg_wbdata         := mem_wbdata
  wb_reg_ctrl_rf_wen    := mem_reg_ctrl_rf_wen


  //**********************************
  // External Signals

  // datapath to controlpath outputs
  io.dat.if_valid   := if_reg_valid
  io.dat.if_tid     := if_reg_tid
  io.dat.dec_valid  := dec_reg_valid
  io.dat.dec_inst   := dec_reg_inst
  io.dat.dec_tid    := dec_reg_tid
  io.dat.exe_valid  := exe_reg_valid
  io.dat.exe_tid    := exe_reg_tid
  io.dat.exe_br_eq  := (exe_reg_rs1_data === exe_reg_rs2_data)
  io.dat.exe_br_lt  := (exe_reg_rs1_data.toSInt < exe_reg_rs2_data.toSInt) 
  io.dat.exe_br_ltu := (exe_reg_rs1_data.toUInt < exe_reg_rs2_data.toUInt)
  io.dat.exe_br_type:= exe_reg_ctrl_br_type
  //io.dat.exe_du_wait:= exe_du_wait //ifdu

  // Ptp signals
  if(conf.getTime) {
    io.top.exe_ns_clock := exe_reg_ns_clock
  }
}


}
