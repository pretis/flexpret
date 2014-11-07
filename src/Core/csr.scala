/******************************************************************************
File: csr.scala
Description: Control and status registers.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

// TODO: supervisor spec
class CSR(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new Bundle {
    val rw = new Bundle {
      val addr = UInt(INPUT, 12)
      val thread = UInt(INPUT, conf.threadBits)
      val csr_type = UInt(INPUT, CSR_WI)
      val write = Bool(INPUT)
      val data_in = Bits(INPUT, 32)
      val data_out = Bits(OUTPUT, 32)
    }
    val slots   = Vec.fill(8) { UInt(OUTPUT, SLOT_WI) }
    val tmodes  = Vec.fill(conf.threads) { UInt(OUTPUT, TMODE_WI) }
    val evec   = UInt(OUTPUT, 32) //ifex 
    val host    = new HostIO()
    val gpio    = new GPIO()
  }
 
 
 // Read/modify/write for input data depending on type.
 val data_out = Bits()
 val data_in = MuxLookup(io.rw.csr_type, io.rw.data_in, Array(
    CSR_S -> (data_out | io.rw.data_in),
    CSR_C -> (data_out & ~io.rw.data_in),
    CSR_W -> io.rw.data_in
  ))

 
  val reg_slots = Vec(conf.initialSlots.map(i => Reg(init = i)))
  val reg_tmodes = Vec(conf.initialTmodes.map(i => Reg(init = i)))
  val reg_evecs = Vec.fill(conf.threads) { Reg(UInt()) } //ifex
  val reg_to_host = Reg(init = Bits(0, 32))
  val reg_gpos = Vec.fill(conf.threads) { Reg(UInt(width = conf.gpoBits)) }
  val reg_time = Reg(init = UInt(0, conf.timeBits))
  val reg_du_time = Vec.fill(conf.threads) { Reg(UInt(width = conf.timeBits+1)) }
  val reg_du_en = Vec.fill(conf.threads) { Reg(init = Bool(false)) }

  
  def compare_addr(csr: Int): Bool = { io.rw.addr === UInt(csr) }

  // Update CSR register
  when(io.rw.write) {
    when(compare_addr(CSRs.tohost)) { reg_to_host := data_in }
    when(compare_addr(CSRs.slots)) { for((slot, i) <- reg_slots.view.zipWithIndex) { slot := data_in(4*i+3, 4*i) } }
    when(compare_addr(CSRs.tmodes)) { for((tmode, i) <- reg_tmodes.view.zipWithIndex) { tmode := data_in(2*i+1, 2*i) } }
    when(compare_addr(CSRs.gpos)) { reg_gpos(io.rw.thread) := data_in(conf.gpoBits-1, 0) }
    if(conf.exceptions) {
      when(compare_addr(CSRs.evec)) { reg_evecs(io.rw.thread) := data_in } //ifex
    }
    if(conf.delayUntil) {
      when(compare_addr(CSRs.delay_until)) { 
        reg_du_time(io.rw.thread) := data_in // Store time to compare against
        reg_du_en(io.rw.thread) := Bool(true) // Start compare
        reg_tmodes(io.rw.thread) := reg_tmodes(io.rw.thread) | TMODE_OR_Z // Sleep thread
      } //ifdu
    }
  }

  val def_data_out = reg_to_host
  data_out :=
    Mux(compare_addr(CSRs.tohost), reg_to_host,
    Mux(compare_addr(CSRs.gpos), (if(conf.gpoBits < 32) Cat(Bits(0, 32-conf.gpoBits), reg_gpos(io.rw.thread)) else reg_gpos(io.rw.thread)),
    Mux(compare_addr(CSRs.slots), reg_slots.toBits(),
    Mux(compare_addr(CSRs.tmodes), Cat(Bits(0, 32-2*conf.threads), reg_tmodes.toBits()),
    Mux(compare_addr(CSRs.hartid), Cat(Bits(0, 32-conf.threadBits), io.rw.thread),
    Mux(compare_addr(CSRs.evec), (if(conf.exceptions) reg_evecs(io.rw.thread) else def_data_out), //ifex
    Mux(compare_addr(CSRs.time), (if(conf.getTime) Cat(Bits(0, 32-conf.timeBits), reg_time) else def_data_out),
        def_data_out))))))) // default

  // Update CSR (overwrite write)
  if(conf.getTime) {
    reg_time := reg_time + UInt(conf.timeInc)
  }

  // Delay until //ifdu
  // TODO: could allow larger range if top bit cleared on roll-over
  if(conf.delayUntil) {
    for(tid <- 0 until conf.threads) {
      // Compare count
      when(reg_du_en(tid) && reg_time >= reg_du_time(tid)) {
        // Handle overflow
        when(!(reg_time(conf.timeBits-1) === UInt(1) && reg_du_time(tid)(conf.timeBits) === UInt(1))) {
          // Wake up thread
          reg_tmodes(tid) := reg_tmodes(tid) & TMODE_AND_A
          reg_du_en(tid) := Bool(false)
        }
      }
    }
  }
  

  io.rw.data_out := data_out
  io.slots := reg_slots
  io.tmodes := reg_tmodes
  if(conf.exceptions) {
    io.evec := reg_evecs(io.rw.thread) //ifex
  }
  io.host.to_host := reg_to_host
  io.gpio.out := reg_gpos


}
