/******************************************************************************
pcr.scala:
  Privileged control registers (PCR) for processor configuration, testing, etc.
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
import CoreConstants._

class HostIo extends Bundle
{
  val tohost     = Bits(OUTPUT, XPRLEN)
//  val fromhost   = Bits(INPUT, XPRLEN)
}

class StatIo(threadBits: Int) extends Bundle
{
  val ivalid = Bool(INPUT)
  val cvalid = Bool(INPUT)
  val tid = Bits(INPUT, threadBits)
}

class DpathPcrIo(conf: CoreConfig) extends Bundle
{
  val fcn        = UInt(INPUT, 2)
  val req_addr   = UInt(INPUT, 5)
  val req_tid    = UInt(INPUT, conf.threadBits)
  val req_wdata  = Bits(INPUT, XPRLEN)
  val resp_data  = Bits(OUTPUT, XPRLEN)
  val host       = new HostIo()
  val schedule   = Bits(OUTPUT, 32)
  val thread_modes = Vec.fill(conf.threads) { UInt(OUTPUT, 2) } //todo simpilfy
  val stat       = new StatIo(conf.threadBits)
  val exception  = Vec.fill(conf.threads) { Bool(INPUT) }
  val epc        = Vec.fill(conf.threads) { Bits(INPUT, 32) }
  val evec       = Vec.fill(conf.threads) { Bits(OUTPUT, 32) }
  val tsup       = Vec.fill(conf.threads) { Bool(OUTPUT) } // TODO to vec conf.threads
  val tsleep     = Bool(INPUT)
  val tsleep_tid = UInt(INPUT, conf.threadBits)
  val mem_shared = UInt(OUTPUT, conf.dSpmPageBits) //1kb sections
  val mem_priv_l = Vec.fill(conf.threads) { UInt(OUTPUT, conf.dSpmPageBits) }
  val mem_priv_h = Vec.fill(conf.threads) { UInt(OUTPUT, conf.dSpmPageBits) }

}

// TODO: change how connected in pipeline? keep in exe stage or put in dec/ex
// TODO: cleanup

class Pcr(conf: CoreConfig) extends Module
{
  val io = new DpathPcrIo(conf)

  // Status register 
  // 0.8 : IM.8 : 0.7 : VM : S64 : U64 : S : PS : 0.2 : EF : ET
  val reg_status_flexpret = Bool(conf.flex) // If false, threads >=4 and no bypass.
  val reg_status_threads = UInt(conf.threads-1, SR_THREADS_WIDTH) // Highest thread ID.
  val reg_status_tsup = Vec.fill(conf.threads) { Reg(init=Bool(true)) } // TODO: currently on 4 threads with supervisory mode

  val reg_status_im  = Bits(0, SR_IM_WIDTH) //Reg(init = Bits(0,SR_IM_WIDTH))  // interrupt mask
  
  val reg_status_vm  = Bool(false)                          // virtual memory? (not supported)
  val reg_status_sx  = Bool(false)                          // RV64S? (not supported)
  val reg_status_ux  = Bool(false)                          // RV64U? (not supported)
  
  val reg_status_s   = Bool(false)  //Reg(init = Bool(true))           // in supervisor mode? TODO: implement
  val reg_status_ps  = Bool(false) //Reg(init = Bool(false))          // in super before exception TODO: implement
 
  val reg_status_ec  = Bool(false)                          // RVC (compression) support? (not supported)
  val reg_status_ev  = Bool(false)                          // vector machine support? (not supported)
  val reg_status_ef  = Bool(false)                          // floating point? (not supported)
  val reg_status_et  = Bool(false)                          // exceptions turned on? (not supported) TODO: implement
  
  val reg_status = Cat(reg_status_flexpret,
                       reg_status_threads,
                       if(conf.threads > 3) { reg_status_tsup(3) } else { Bool(false) },
                       if(conf.threads > 2) { reg_status_tsup(2) } else { Bool(false) },
                       if(conf.threads > 1) { reg_status_tsup(1) } else { Bool(false) },
                       reg_status_tsup(0),
                       reg_status_im, 
                       Bits(0,7),
                       reg_status_vm,  
                       reg_status_sx, 
                       reg_status_ux, 
                       reg_status_s,  
                       reg_status_ps, 
                       reg_status_ec, 
                       reg_status_ev, 
                       reg_status_ef, 
                       reg_status_et)


  //TODO: thread can currently only set its own l and h
  val reg_shared = Reg(init = UInt(-1,conf.dSpmPageBits))
  reg_shared := reg_shared
  val reg_priv_l = Vec.fill(conf.threads) { Reg(init = UInt(0,conf.dSpmPageBits)) }
  val reg_priv_h = Vec.fill(conf.threads) { Reg(init = UInt(-1,conf.dSpmPageBits)) }

  io.mem_shared := reg_shared
  io.mem_priv_l := reg_priv_l
  io.mem_priv_h := reg_priv_h

  val reg_tohost   = Reg(init = Bits(0, XPRLEN)) //TODO remove?
 // val reg_fromhost = Reg(init = Bits(0, XPRLEN))
  // TODO: put enable bits at front?
  val reg_schedule = Reg(init = Bits("b1111_1111_1111_1111_1111_1111_1111_0000", XPRLEN)) // TODO initial?
  val reg_thread_modes = Vec.fill(conf.threads) { Reg(init = UInt(0, 2)) } //TODO to conf.thread
  //tsleep
  when(io.tsleep) {
      reg_thread_modes(io.tsleep_tid) := reg_thread_modes(io.tsleep_tid) | UInt(1,2)
  }
  for(i <- 0 until conf.threads) {
    when(io.exception(i)) {
      reg_thread_modes(i) := reg_thread_modes(i) & UInt(2,2)
    }
  }

  //TODO support 2+ threads
  //val thread_modes = Cat(Bits(0, 24), reg_thread_modes(3), reg_thread_modes(2), reg_thread_modes(1), reg_thread_modes(0)) //TODO cleaner
  
  // Default output data.
  io.resp_data := reg_status

  // Read from PCR.
  when(io.fcn === PCR_F)
  {
     switch (io.req_addr) 
     {
        is (PCR_STATUS)   { io.resp_data := reg_status   }
//        is (PCR_SHARED)   { io.resp_data := Cat(Bits(0, 32-conf.dSpmPageBits), reg_shared) }
 //       is (PCR_PRIV_L)   { io.resp_data := Cat(Bits(0, 32-conf.dSpmPageBits), reg_priv_l(io.req_tid)) }
 //       is (PCR_PRIV_H)   { io.resp_data := Cat(Bits(0, 32-conf.dSpmPageBits), reg_priv_h(io.req_tid)) }
        is (PCR_SCHEDULE) { io.resp_data := reg_schedule }
      //  is (PCR_TMODES) { io.resp_data := thread_modes } 
        is (PCR_TID)      { io.resp_data := Cat(Bits(0, XPRLEN-conf.threadBits), io.req_tid) }
        is (PCR_TOHOST)   { io.resp_data := reg_tohost   }
     }
  }
  // Write to PCR.
  when(io.fcn === PCR_T)
  {
     switch (io.req_addr) 
     {
        is (PCR_TOHOST)   { reg_tohost :=   io.req_wdata }
        is (PCR_SHARED)   { reg_shared := Mux(reg_status_tsup(io.req_tid),io.req_wdata(conf.dSpmPageBits-1,0).toUInt,reg_shared) }
        // upper 3 bits are tid
        is (PCR_PRIV_L)   { reg_priv_l(io.req_wdata(29+conf.threadBits-1,29).toUInt) :=
        Mux(reg_status_tsup(io.req_tid),io.req_wdata(conf.dSpmPageBits-1,0).toUInt,reg_priv_l(io.req_wdata(29+conf.threadBits-1,29).toUInt)) }
        is (PCR_PRIV_H)   { reg_priv_h(io.req_wdata(29+conf.threadBits-1,29).toUInt) :=
        Mux(reg_status_tsup(io.req_tid),io.req_wdata(conf.dSpmPageBits-1,0).toUInt,reg_priv_h(io.req_wdata(29+conf.threadBits-1,29).toUInt)) }
        is (PCR_SCHEDULE) { reg_schedule := Mux(reg_status_tsup(io.req_tid), io.req_wdata, reg_schedule) }
        is (PCR_TMODES) { 
          when(reg_status_tsup(io.req_tid)) {
            for(i <- 0 until conf.threads) {
              reg_thread_modes(i) := io.req_wdata(2*i+1,2*i).toUInt
            }
          }
        } //TODO cleaner
        
        is (PCR_TSUP) { reg_status_tsup(io.req_tid) := Bool(false) } // TODO: currently can only leave
     }
  }

  // Exceptions
  if(conf.exceptions) {
    val reg_epc = Vec.fill(conf.threads) { Reg(outType=Bits()) }
    for(tid <- 0 until conf.threads) {
      when(io.exception(tid)) {
        reg_epc(tid) := io.epc(tid)
      }
    }
    val reg_evec = Vec.fill(conf.threads) { Reg(init = EVEC_INIT) }
    when(io.fcn === PCR_F && io.req_addr === PCR_EPC) {
      io.resp_data := reg_epc(io.req_tid)
    }
    when(io.fcn === PCR_T && io.req_addr === PCR_EVEC) {
      reg_evec(io.req_tid) := io.req_wdata
    }
    io.evec := reg_evec
  }

  // External signals for tohost.
  io.host.tohost := reg_tohost
  io.schedule    := reg_schedule
  io.thread_modes := reg_thread_modes
  io.tsup := reg_status_tsup
  //reg_fromhost   := io.host.fromhost  

  // Stats
  if(conf.stats) {
    val inst_counter  = Vec.fill(conf.threads) { Reg(init=UInt(0, XPRLEN)) }
    val cycle_counter = Vec.fill(conf.threads) { Reg(init=UInt(0, XPRLEN)) }
    when(io.stat.ivalid) {
      inst_counter(io.stat.tid) := inst_counter(io.stat.tid) + UInt(1)
    }
    when(io.stat.cvalid) {
      cycle_counter(io.stat.tid) := cycle_counter(io.stat.tid) + UInt(1)
    }
    // Write to either will reset counters.
    when((io.fcn === PCR_T) && (io.req_addr === PCR_CYCLES || io.req_addr === PCR_INSTS)) {
      inst_counter(io.req_tid) := UInt(0)
      cycle_counter(io.req_tid) := UInt(0)
    }
    when(io.fcn === PCR_F) {
      when(io.req_addr === PCR_INSTS) { io.resp_data := inst_counter(io.req_tid) }
      when(io.req_addr === PCR_CYCLES) { io.resp_data := cycle_counter(io.req_tid) }
    }
  }

}

}
