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
      val valid = Bool(INPUT)
    }
    // thread scheduler
    val slots           = Vec.fill(8) { UInt(OUTPUT, SLOT_WI) }
    val tmodes          = Vec.fill(conf.threads) { UInt(OUTPUT, TMODE_WI) }
    // exception handling
    val kill            = Bool(INPUT) // prevent commit
    val exception       = Bool(INPUT) // exception occurred
    val epc             = UInt(INPUT, 32) // PC of uncommitted instruction
    val cause           = UInt(INPUT, CAUSE_WI)
    val evecs           = Vec.fill(conf.threads) { UInt(OUTPUT, 32) }
    // timing
    val sleep           = Bool(INPUT) // valid DU inst
    val ie              = Bool(INPUT) // valid IE inst
    val ee              = Bool(INPUT) // valid EE inst
    val expire          = Bool(OUTPUT) // DU, WU time expired
    val dec_tid         = UInt(INPUT, conf.threadBits)
    // privileged
    val sret            = Bool(INPUT) // valid sret instruction (ignores exception)
    // I/O
    val host            = new HostIO()
    val gpio            = new GPIO()
    val int_exts        = Vec.fill(conf.threads) { Bool(INPUT) }
    // memory protection
    val imem_protection = Vec.fill(conf.memRegions) { UInt(OUTPUT, MEMP_WI) }
    val dmem_protection = Vec.fill(conf.memRegions) { UInt(OUTPUT, MEMP_WI) }
    // stats
    val cycle           = Bool(INPUT)
    val instret         = Bool(INPUT)
    // interrupts/exceptions
    val int_expire      = Bool(OUTPUT) // IE time expired
    val exc_expire      = Bool(OUTPUT) // EE time expired
    val int_ext         = Bool(OUTPUT) // external interrupt
    val priv_fault      = Bool(OUTPUT) // CSR permission
  }

 
  // ************************************************************
  // CSR state
  
  // thread scheduler
  val reg_slots           = Vec(conf.initialSlots.map(i => Reg(init = i)))
  val reg_tmodes          = Vec(conf.initialTmodes.map(i => Reg(init = i)))
  // exception handling
  val reg_evecs           = Vec.fill(conf.threads) { Reg(UInt()) }
  val reg_epcs            = Vec.fill(conf.threads) { Reg(UInt()) } // RO?
  val reg_causes          = Vec.fill(conf.threads) { Reg(UInt()) } // RO
  val reg_sup0            = Vec.fill(conf.threads) { Reg(UInt()) }
  // timing instructions
  val reg_time            = Reg(init = UInt(0, 64)) // RO, less bits if !conf.stats
  val reg_compare         = Vec.fill(conf.threads) { Reg(UInt(width = conf.timeBits)) }
  // I/O
  val reg_to_host         = Reg(init = Bits(0, 32))
  val reg_gpis            = Vec(conf.gpiPortSizes.map(i => Reg(UInt(width = i)))) // RO
  val reg_gpos            = Vec(conf.gpoPortSizes.map(i => Reg(init = UInt(0, i))))
  // protection
  val reg_gpo_protection  = Vec(conf.initialGpo.map(i => Reg(init = i)))
  val reg_imem_protection = Vec(conf.initialIMem.map(i => Reg(init = i)))
  val reg_dmem_protection = Vec(conf.initialDMem.map(i => Reg(init = i)))
  // stats
  val reg_cycle           = Vec.fill(conf.threads) { Reg(UInt(width = 64)) } // RO
  val reg_instret         = Vec.fill(conf.threads) { Reg(UInt(width = 64)) } // RO
  // status
  val reg_mtie            = Vec.fill(conf.threads) { Reg(init = Bool(false)) }
  val reg_prv1            = Vec.fill(conf.threads) { Reg(init = UInt(0, 2)) }
  val reg_ie1             = Vec.fill(conf.threads) { Reg(init = Bool(false)) }
  val reg_prv             = Vec.fill(conf.threads) { Reg(init = UInt(3, 2)) }
  val reg_ie              = Vec.fill(conf.threads) { Reg(init = Bool(false)) }
  val reg_msip            = Vec.fill(conf.threads) { Reg(init = Bool(false)) }
  
  // Invisible 
  val reg_timer = Vec.fill(conf.threads) { Reg(init = TIMER_OFF) }

  // for reading of status CSR
  val status = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) {
    status(tid) := Cat(Bits(1,1), Bits(0,4), reg_mtie(tid), Bits(0,20), reg_prv1(tid), reg_ie1(tid), reg_prv(tid), reg_ie(tid), reg_msip(tid), Bits(0,3))
  }
  

  // ************************************************************
  // CSR I/O
  
  def compare_addr(csr: Int): Bool = { io.rw.addr === UInt(csr) }
  
  // Read/modify/write for input data depending on type.
  val data_out = Bits()
  val data_in = MuxLookup(io.rw.csr_type, io.rw.data_in, Array(
    CSR_S -> (data_out | io.rw.data_in),
    CSR_C -> (data_out & ~io.rw.data_in),
    CSR_W -> io.rw.data_in
    ))
  
  // check permission (if privileged)
  val priv_fault = Bool()
  priv_fault := Bool(false) // default value
  if(conf.privilegedMode) {
    val addr_read_only = io.rw.addr(11,10) === UInt(3)
    val addr_no_priv = (io.rw.addr(9,8) != UInt(0)) && (reg_prv(io.rw.thread) === UInt(0,2))
    when(io.rw.write && (addr_read_only || addr_no_priv)) {
      priv_fault := Bool(true)
    }
    // TODO: read without permission?
  }


  // ************************************************************
  // CSR write (may be later over-written)
  
  val write = io.rw.write && !priv_fault && !io.kill
  when(write) {
    when(compare_addr(CSRs.slots)) { 
      for((slot, i) <- reg_slots.view.zipWithIndex) { slot := data_in(4*i+3, 4*i) }
    }
    when(compare_addr(CSRs.tmodes)) { 
      for((tmode, i) <- reg_tmodes.view.zipWithIndex) { tmode := data_in(2*i+1, 2*i) } 
      // also modified by DU/WU sleep and wake, but not in same cycle as valid
      // CSR write instruction (for same thread)
    }
    if(conf.exceptions) {
      when(compare_addr(CSRs.evec)) { reg_evecs(io.rw.thread) := data_in }
      when(compare_addr(CSRs.sup0)) { reg_sup0(io.rw.thread) := data_in }
    }
    if(conf.delayUntil || conf.interruptExpire) {
      when(compare_addr(CSRs.compare)) { 
        reg_compare(io.rw.thread) := data_in(conf.timeBits-1,0)
        reg_timer(io.rw.thread) := TIMER_OFF
      }
    }
    when(compare_addr(CSRs.tohost)) { reg_to_host := data_in }
    for(i <- 0 until conf.gpoPortSizes.length) {
      when(compare_addr(CSRs.gpoBase + i)) {
        if(conf.gpioProtection) {
          when(((reg_gpo_protection(i) === MEMP_SH) || (reg_gpo_protection(i)(conf.threadBits-1,0) === io.rw.thread)) && (reg_gpo_protection(i) != MEMP_RO)) {
            reg_gpos(i) := data_in(conf.gpoPortSizes(i)-1, 0)
          }
        } else {
          reg_gpos(i) := data_in(conf.gpoPortSizes(i)-1, 0)
        }
      }
    }
    if(conf.memProtection) {
      when(compare_addr(CSRs.iMemProtection)) { 
        for((region, i) <- reg_imem_protection.view.zipWithIndex) { region := data_in(4*i+3, 4*i) } 
      }
      when(compare_addr(CSRs.dMemProtection)) { 
        for((region, i) <- reg_dmem_protection.view.zipWithIndex) { region := data_in(4*i+3, 4*i) } 
      }
    }
    if(conf.gpioProtection) {
      when(compare_addr(CSRs.gpoProtection)) { 
        for((port, i) <- reg_gpo_protection.view.zipWithIndex) { port := data_in(4*i+3, 4*i) } 
      }
    }
    when(compare_addr(CSRs.status)) {
      if(conf.exceptions) {
        reg_ie(io.rw.thread)   := data_in(4).toBool
      }
      if(conf.interruptExpire) {
        reg_mtie(io.rw.thread) := data_in(26).toBool
      }
      if(conf.externalInterrupt) {
        reg_msip(io.rw.thread) := data_in(3).toBool
      }
    }
  }
  
  // ************************************************************
  // CSR read
  
  def zero_extend(base: Bits, len: Int): Bits = if(len < 32) Cat(Bits(0, 32-len), base) else base
  data_out := Bits(0, 32)
  if(conf.threads > 1) {
    when(compare_addr(CSRs.slots)) { data_out := reg_slots.toBits }
    when(compare_addr(CSRs.hartid)) { data_out := zero_extend(io.rw.thread, conf.threadBits) }
  }
  when(compare_addr(CSRs.tmodes)) {
    data_out := zero_extend(reg_tmodes.toBits, 2*conf.threads)
  }
  if(conf.exceptions) {
    when(compare_addr(CSRs.evec))  { data_out := reg_evecs(io.rw.thread) }
    when(compare_addr(CSRs.epc))   { data_out := reg_epcs(io.rw.thread) }
    when(compare_addr(CSRs.cause)) { 
      data_out := Cat(reg_causes(io.rw.thread)(CAUSE_WI-1), Bits(0,32-CAUSE_WI), reg_causes(io.rw.thread)(CAUSE_WI-2,0))
    }
    when(compare_addr(CSRs.sup0)) { data_out := reg_sup0(io.rw.thread) }
  }
  if(conf.getTime) {
    when(compare_addr(CSRs.clock)) { 
      data_out := zero_extend(reg_time(conf.timeBits-1,0).toBits, conf.timeBits)
    }
  }
  when(compare_addr(CSRs.tohost)) { data_out := reg_to_host }
  for(i <- 0 until conf.gpiPortSizes.length) {
    when(compare_addr(CSRs.gpiBase + i)) {
      data_out := zero_extend(reg_gpis(i).toBits, conf.gpiPortSizes(i))
    }
  }
  for(i <- 0 until conf.gpoPortSizes.length) {
    when(compare_addr(CSRs.gpoBase + i)) {
      data_out := zero_extend(reg_gpos(i).toBits, conf.gpoPortSizes(i))
    }
  }
  // TODO: bits?
  if(conf.gpioProtection) {
    when(compare_addr(CSRs.gpoProtection)) { data_out := reg_gpo_protection.toBits() }
  }
  if(conf.memProtection) {
    when(compare_addr(CSRs.iMemProtection)) { data_out := reg_imem_protection.toBits() }
    when(compare_addr(CSRs.dMemProtection)) { data_out := reg_dmem_protection.toBits() }
  }
  if(conf.stats) {
    when(compare_addr(CSRs.time)) { data_out := reg_time(31,0) }
    when(compare_addr(CSRs.cycle)) { data_out := reg_cycle(io.rw.thread)(31,0) }
    when(compare_addr(CSRs.instret)) { data_out := reg_instret(io.rw.thread)(31,0) }
    when(compare_addr(CSRs.timeh)) { data_out := reg_time(63,32) }
    when(compare_addr(CSRs.cycleh)) { data_out := reg_cycle(io.rw.thread)(63,32) }
    when(compare_addr(CSRs.instreth)) { data_out := reg_instret(io.rw.thread)(63,32) }
  }
  when(compare_addr(CSRs.status)) { data_out := status(io.rw.thread) }

  // ************************************************************
  // State update (override any CSR write)
  
  // Thread scheduler
  // TODO: need to sleep at end exe or wait a cycle?
  val sleep = Bool()
  sleep := Bool(false) // default value
  when(sleep) { reg_tmodes(io.rw.thread) := reg_tmodes(io.rw.thread) | TMODE_OR_Z }
  val wake = Vec.fill(conf.threads) { Bool() }
  for(tid <- 0 until conf.threads) {
    wake(tid) := Bool(false) // default value
    // Multiple threads can be woken in any given cycle (compare expire or
    // external interrupt).
    when(wake(tid)) { reg_tmodes(tid) := reg_tmodes(tid) & TMODE_AND_A }
    // TODO: what happens with CSR write?
  }
  
  // exception handling
  if(conf.exceptions) {
    when(io.exception) {
      reg_epcs(io.rw.thread) := io.epc
      reg_causes(io.rw.thread) := io.cause
    }
  }

  // timing instructions
  //val expired = Vec.fill(conf.threads) { Reg(Bool()) } // needs 2 cycle cmp
  val expired = Vec.fill(conf.threads) { Bool() }
  // default value
  for(tid <- 0 until conf.threads) { expired(tid) := Bool(false) }

  // update time every cycle
  if(conf.getTime) {
    reg_time := reg_time + UInt(conf.timeInc)
  }

  // unless conf.roundRobin, use comparator for each thread
  // otherwise wake precision limited by number of comparators
  if(conf.delayUntil || conf.interruptExpire) {
    for(tid <- 0 until conf.threads) {
      // Each value compared to current time
      expired(tid) := (reg_time(conf.timeBits-1,0) - reg_compare(tid))(conf.timeBits-1) === UInt(0, 1)
      if(conf.roundRobin) {
        when(io.rw.thread != UInt(tid)) { expired(tid) := Bool(false) }
      }
    }
  }

  // compare value should already be set
  if(conf.delayUntil) {
    // DU/WU instruction sleeps thread and sets timer mode
    when(io.sleep) {
      sleep := Bool(true)
      reg_timer(io.rw.thread) := TIMER_DU_WU
    }
    // Check each thread for expiration and wake
    for(tid <- 0 until conf.threads) {
      when((reg_timer(tid) === TIMER_DU_WU) && expired(tid)) {
        wake(tid) := Bool(true)
        reg_timer(tid) := TIMER_OFF
      }
    }
  }

  // Only when thread is active, so only one time comparison needed
  val exc_expire = Bool()
  exc_expire := Bool(false)
  val int_expire = Bool()
  int_expire := Bool(false)
  if(conf.interruptExpire) {
    when(io.ee) {
      reg_timer(io.rw.thread) := TIMER_EE
    }
    // send exception, but may not have priority
    when(io.rw.valid && (reg_timer(io.rw.thread) === TIMER_EE) && expired(io.rw.thread)) {
      reg_timer(io.rw.thread) := TIMER_OFF
      exc_expire := Bool(true)
    }
    when(io.ie) {
      reg_timer(io.rw.thread) := TIMER_IE
    }
    // capture interrupt and stop comparion
    val mtie = Bool()
    mtie := Bool(false) // default
    when(io.rw.valid && (reg_timer(io.rw.thread) === TIMER_IE) && expired(io.rw.thread)) {
      reg_timer(io.rw.thread) := TIMER_OFF
      mtie := Bool(true)
      reg_mtie(io.rw.thread) := Bool(true)
    }
    // Only send interrupt to control if past or current cycle has timer
    // interrupt
    int_expire := reg_ie(io.rw.thread) && (reg_mtie(io.rw.thread) || mtie)
  }

  // Input handling
  // Every cycle, register GPI pins
  reg_gpis := io.gpio.in

  // External interrupt handling
  val int_ext = Bool()
  int_ext := Bool(false)
  if(conf.causes.contains(Causes.external_int)) {
    for(tid <- 0 until conf.threads) {
      // set interrupt as pending, only cleared once handled, and wake thread
      when(io.int_exts(tid)) {
        reg_msip(io.rw.thread) := Bool(true)
        wake(tid) := Bool(true)
      }
    }
    // Only send interrupt to control if past cycle has external
    // interrupt
    int_ext := reg_ie(io.rw.thread) && reg_msip(io.rw.thread)
  }

  // stats (not designed for performance)
  if(conf.stats) {
    when(io.cycle) { reg_cycle(io.rw.thread) := reg_cycle(io.rw.thread) + UInt(1) }
    when(io.instret) { reg_instret(io.rw.thread) := reg_instret(io.rw.thread) + UInt(1) }
  }

  // Privileged mode
  if(conf.privilegedMode) {
    when(io.exception) {
      // save current prv and ie
      reg_prv1 := reg_prv
      reg_ie1 := reg_ie
      // privileged mode with interrupts disabled
      reg_prv := UInt(3, 2)
      reg_ie := Bool(false)
    } .elsewhen(io.sret) {
      // restore
      reg_prv := reg_prv1
      reg_ie := reg_ie1
    }
  } else {
    when(io.exception) {
      reg_ie := Bool(false)
    }
  }


  io.rw.data_out := data_out
  io.slots := reg_slots
  io.tmodes := reg_tmodes
  if(conf.exceptions) {
    io.evecs := reg_evecs
  }
  io.expire := expired(io.rw.thread)
  io.host.to_host := reg_to_host
  io.gpio.out := reg_gpos
  io.imem_protection := reg_imem_protection
  io.dmem_protection := reg_dmem_protection
  io.exc_expire := exc_expire
  io.int_expire := int_expire
  io.int_ext := int_ext
  io.priv_fault := priv_fault


}
