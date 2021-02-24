/******************************************************************************
File: csr.scala
Description: Control and status registers.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util._

import Core.Causes
import Core.CSRs
import Core.FlexpretConstants._

class CSR(implicit val conf: FlexpretConfiguration) extends Module {
  val io = IO(new Bundle {
    val rw = new Bundle {
      val addr = Input(UInt(12.W))
      val thread = Input(UInt(conf.threadBits.W))
      val csr_type = Input(UInt(CSR_WI.W))
      val write = Input(Bool())
      val data_in = Input(UInt(32.W))
      // Note: data_out is read combinationally!
      val data_out = Output(UInt(32.W))
      val valid = Input(Bool())
    }
    // thread scheduler
    val slots = Output(Vec(8, UInt(SLOT_WI.W)))
    val tmodes = Output(Vec(conf.threads, UInt(TMODE_WI.W)))
    // exception handling
    val kill = Input(Bool()) // prevent commit
    val exception = Input(Bool()) // exception occurred
    val epc = Input(UInt(32.W)) // PC of uncommitted instruction
    val cause = Input(UInt(CAUSE_WI.W))
    val evecs = Output(Vec(conf.threads, UInt(32.W)))
    // timing
    val sleep = Input(Bool()) // valid DU inst
    val ie = Input(Bool()) // valid IE inst
    val ee = Input(Bool()) // valid EE inst
    val expire = Output(Bool()) // DU, WU time expired
    val dec_tid = Input(UInt(conf.threadBits.W))
    // privileged
    val sret = Input(Bool()) // valid sret instruction (ignores exception)
    // I/O
    val host = new HostIO()
    val gpio = new GPIO()
    val int_exts = Input(Vec(conf.threads, Bool()))
    // memory protection
    val imem_protection = Output(Vec(conf.memRegions, UInt(MEMP_WI.W)))
    val dmem_protection = Output(Vec(conf.memRegions, UInt(MEMP_WI.W)))
    // stats
    val cycle = Input(Bool())
    val instret = Input(Bool())
    // interrupts/exceptions
    val int_expire = Output(Bool()) // IE time expired
    val exc_expire = Output(Bool()) // EE time expired
    val int_ext = Output(Bool()) // external interrupt
    val priv_fault = Output(Bool()) // CSR permission
  })

  // ************************************************************
  // CSR state

  // thread scheduler
  val reg_slots = RegInit(VecInit(conf.initialSlots.map(i => i).toSeq)) // i => i since they are already UInts
  val reg_tmodes = RegInit(VecInit(conf.initialTmodes.map(i => i).toSeq))
  // exception handling
  val reg_evecs = Reg(Vec(conf.threads, UInt()))
  val reg_epcs = Reg(Vec(conf.threads, UInt())) // RO?
  val reg_causes = Reg(Vec(conf.threads, UInt())) // RO
  val reg_sup0 = Reg(Vec(conf.threads, UInt()))
  // timing instructions
  val reg_time = RegInit(0.U(64.W)) // RO, less bits if !conf.stats
  val reg_compare = Reg(Vec(conf.threads, UInt(conf.timeBits.W)))
  // I/O
  val reg_to_host = RegInit(0.U(32.W))
  val reg_gpis: Seq[UInt] = conf.gpiPortSizes.map(i => Reg(UInt(i.W))).toSeq // RO
  val reg_gpos: Seq[UInt] = conf.gpoPortSizes.map(i => RegInit(0.U(i.W))).toSeq
  // protection
  val reg_gpo_protection = RegInit(VecInit(conf.initialGpo.map(i => i).toSeq))
  val reg_imem_protection = RegInit(VecInit(conf.initialIMem.map(i => i).toSeq))
  val reg_dmem_protection = RegInit(VecInit(conf.initialDMem.map(i => i).toSeq))
  // stats
  val reg_cycle = Reg(Vec(conf.threads, UInt(64.W))) // RO
  val reg_instret = Reg(Vec(conf.threads, UInt(64.W))) // RO
  // status
  val reg_mtie = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val reg_prv1 = RegInit(VecInit(Seq.fill(conf.threads) { 0.U(2.W) }))
  val reg_ie1 = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val reg_prv = RegInit(VecInit(Seq.fill(conf.threads) { 3.U(2.W) }))
  val reg_ie = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val reg_msip = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))

  // Invisible
  val reg_timer = RegInit(VecInit(Seq.fill(conf.threads) { TIMER_OFF }))

  // for reading of status CSR
  val status = Wire(Vec(conf.threads, UInt()))
  for (tid <- 0 until conf.threads) {
    status(tid) := Cat(1.U(1.W), 0.U(4.W), reg_mtie(tid), 0.U(20.W), reg_prv1(tid), reg_ie1(tid), reg_prv(tid), reg_ie(tid), reg_msip(tid), 0.U(3.W))
  }


  // ************************************************************
  // CSR I/O

  def compare_addr(csr: Int): Bool = {
    io.rw.addr === csr.U
  }

  // Read/modify/write for input data depending on type.
  val data_out = Wire(UInt())
  val data_in = MuxLookup(io.rw.csr_type, io.rw.data_in, Array(
    CSR_S -> (data_out | io.rw.data_in),
    CSR_C -> (data_out & ~io.rw.data_in),
    CSR_W -> io.rw.data_in
  ))

  // check permission (if privileged)
  val priv_fault = WireInit(false.B) // default value
  if (conf.privilegedMode) {
    val addr_read_only = io.rw.addr(11, 10) === 3.U
    val addr_no_priv = (io.rw.addr(9, 8) =/= 0.U) && (reg_prv(io.rw.thread) === 0.U(2.W))
    when(io.rw.write && (addr_read_only || addr_no_priv)) {
      priv_fault := true.B
    }
    // TODO: read without permission?
  }


  // ************************************************************
  // CSR write (may be later over-written)

  val write = io.rw.write && !priv_fault && !io.kill
  when(write) {
    when(compare_addr(CSRs.slots)) {
      for ((slot, i) <- reg_slots.view.zipWithIndex) {
        slot := data_in(4 * i + 3, 4 * i)
      }
    }
    when(compare_addr(CSRs.tmodes)) {
      for ((tmode, i) <- reg_tmodes.view.zipWithIndex) {
        tmode := data_in(2 * i + 1, 2 * i)
      }
      // also modified by DU/WU sleep and wake, but not in same cycle as valid
      // CSR write instruction (for same thread)
    }
    if (conf.exceptions) {
      when(compare_addr(CSRs.evec)) {
        reg_evecs(io.rw.thread) := data_in
      }
      when(compare_addr(CSRs.sup0)) {
        reg_sup0(io.rw.thread) := data_in
      }
    }
    if (conf.delayUntil || conf.interruptExpire) {
      when(compare_addr(CSRs.compare)) {
        reg_compare(io.rw.thread) := data_in(conf.timeBits - 1, 0)
        reg_timer(io.rw.thread) := TIMER_OFF
      }
    }
    when(compare_addr(CSRs.tohost)) {
      reg_to_host := data_in
    }
    for (i <- 0 until conf.gpoPortSizes.length) {
      when(compare_addr(CSRs.gpoBase + i)) {
        if (conf.gpioProtection) {
          when(((reg_gpo_protection(i) === MEMP_SH) || (reg_gpo_protection(i)(conf.threadBits - 1, 0) === io.rw.thread)) && (reg_gpo_protection(i) =/= MEMP_RO)) {
            reg_gpos(i) := data_in(conf.gpoPortSizes(i) - 1, 0)
          }
        } else {
          reg_gpos(i) := data_in(conf.gpoPortSizes(i) - 1, 0)
        }
      }
    }
    if (conf.memProtection) {
      when(compare_addr(CSRs.iMemProtection)) {
        for ((region, i) <- reg_imem_protection.view.zipWithIndex) {
          region := data_in(4 * i + 3, 4 * i)
        }
      }
      when(compare_addr(CSRs.dMemProtection)) {
        for ((region, i) <- reg_dmem_protection.view.zipWithIndex) {
          region := data_in(4 * i + 3, 4 * i)
        }
      }
    }
    if (conf.gpioProtection) {
      when(compare_addr(CSRs.gpoProtection)) {
        for ((port, i) <- reg_gpo_protection.view.zipWithIndex) {
          port := data_in(4 * i + 3, 4 * i)
        }
      }
    }
    when(compare_addr(CSRs.status)) {
      if (conf.exceptions) {
        reg_ie(io.rw.thread) := data_in(4).asBool
      }
      if (conf.interruptExpire) {
        reg_mtie(io.rw.thread) := data_in(26).asBool
      }
      if (conf.externalInterrupt) {
        reg_msip(io.rw.thread) := data_in(3).asBool
      }
    }
  }

  // ************************************************************
  // CSR read

  def zero_extend(base: Bits, len: Int): Bits = if (len < 32) Cat(0.U((32 - len).W), base) else base

  data_out := 0.U(32.W)
  if (conf.threads > 1) {
    when(compare_addr(CSRs.slots)) {
      data_out := reg_slots.asUInt
    }
    when(compare_addr(CSRs.hartid)) {
      data_out := zero_extend(io.rw.thread, conf.threadBits)
    }
  }
  when(compare_addr(CSRs.tmodes)) {
    data_out := zero_extend(reg_tmodes.asUInt, 2 * conf.threads)
  }
  if (conf.exceptions) {
    when(compare_addr(CSRs.evec)) {
      data_out := reg_evecs(io.rw.thread)
    }
    when(compare_addr(CSRs.epc)) {
      data_out := reg_epcs(io.rw.thread)
    }
    when(compare_addr(CSRs.cause)) {
      data_out := Cat(reg_causes(io.rw.thread)(CAUSE_WI - 1), 0.U((32 - CAUSE_WI).W), reg_causes(io.rw.thread)(CAUSE_WI - 2, 0))
    }
    when(compare_addr(CSRs.sup0)) {
      data_out := reg_sup0(io.rw.thread)
    }
  }
  if (conf.getTime) {
    when(compare_addr(CSRs.clock)) {
      data_out := zero_extend(reg_time(conf.timeBits - 1, 0).asUInt, conf.timeBits)
    }
  }
  when(compare_addr(CSRs.tohost)) {
    data_out := reg_to_host
  }
  for (i <- 0 until conf.gpiPortSizes.length) {
    when(compare_addr(CSRs.gpiBase + i)) {
      data_out := zero_extend(reg_gpis(i).asUInt, conf.gpiPortSizes(i))
    }
  }
  for (i <- 0 until conf.gpoPortSizes.length) {
    when(compare_addr(CSRs.gpoBase + i)) {
      data_out := zero_extend(reg_gpos(i).asUInt, conf.gpoPortSizes(i))
    }
  }
  // TODO: bits?
  if (conf.gpioProtection) {
    when(compare_addr(CSRs.gpoProtection)) {
      data_out := reg_gpo_protection.asUInt
    }
  }
  if (conf.memProtection) {
    when(compare_addr(CSRs.iMemProtection)) {
      data_out := reg_imem_protection.asUInt
    }
    when(compare_addr(CSRs.dMemProtection)) {
      data_out := reg_dmem_protection.asUInt
    }
  }
  if (conf.stats) {
    when(compare_addr(CSRs.time)) {
      data_out := reg_time(31, 0)
    }
    when(compare_addr(CSRs.cycle)) {
      data_out := reg_cycle(io.rw.thread)(31, 0)
    }
    when(compare_addr(CSRs.instret)) {
      data_out := reg_instret(io.rw.thread)(31, 0)
    }
    when(compare_addr(CSRs.timeh)) {
      data_out := reg_time(63, 32)
    }
    when(compare_addr(CSRs.cycleh)) {
      data_out := reg_cycle(io.rw.thread)(63, 32)
    }
    when(compare_addr(CSRs.instreth)) {
      data_out := reg_instret(io.rw.thread)(63, 32)
    }
  }
  when(compare_addr(CSRs.status)) {
    data_out := status(io.rw.thread)
  }

  // ************************************************************
  // State update (override any CSR write)

  // Thread scheduler
  // TODO: need to sleep at end exe or wait a cycle?
  val sleep = WireInit(false.B) // default value
  when(sleep) {
    reg_tmodes(io.rw.thread) := reg_tmodes(io.rw.thread) | TMODE_OR_Z
  }
  val wake = Wire(Vec(conf.threads, Bool()))
  for (tid <- 0 until conf.threads) {
    wake(tid) := false.B // default value
    // Multiple threads can be woken in any given cycle (compare expire or
    // external interrupt).
    when(wake(tid)) {
      reg_tmodes(tid) := reg_tmodes(tid) & TMODE_AND_A
    }
    // TODO: what happens with CSR write?
  }

  // exception handling
  if (conf.exceptions) {
    when(io.exception) {
      reg_epcs(io.rw.thread) := io.epc
      reg_causes(io.rw.thread) := io.cause
    }
  }

  // timing instructions
  // val expired = Reg(Vec(conf.threads, Bool())) // needs 2 cycle cmp
  val expired = Wire(Vec(conf.threads, Bool()))
  // default value
  for (tid <- 0 until conf.threads) {
    expired(tid) := false.B
  }

  // update time every cycle
  if (conf.getTime) {
    reg_time := reg_time + conf.timeInc.U
  }

  // unless conf.roundRobin, use comparator for each thread
  // otherwise wake precision limited by number of comparators
  if (conf.delayUntil || conf.interruptExpire) {
    for (tid <- 0 until conf.threads) {
      // Each value compared to current time
      expired(tid) := (reg_time(conf.timeBits - 1, 0) - reg_compare(tid)) (conf.timeBits - 1) === 0.U(1.W)
      if (conf.roundRobin) {
        when(io.rw.thread =/= tid.U) {
          expired(tid) := false.B
        }
      }
    }
  }

  // compare value should already be set
  if (conf.delayUntil) {
    // DU/WU instruction sleeps thread and sets timer mode
    when(io.sleep) {
      sleep := true.B
      reg_timer(io.rw.thread) := TIMER_DU_WU
    }
    // Check each thread for expiration and wake
    for (tid <- 0 until conf.threads) {
      when((reg_timer(tid) === TIMER_DU_WU) && expired(tid)) {
        wake(tid) := true.B
        reg_timer(tid) := TIMER_OFF
      }
    }
  }

  // Only when thread is active, so only one time comparison needed
  val exc_expire = WireInit(false.B)
  val int_expire = WireInit(false.B)
  if (conf.interruptExpire) {
    when(io.ee) {
      reg_timer(io.rw.thread) := TIMER_EE
    }
    // send exception, but may not have priority
    when(io.rw.valid && (reg_timer(io.rw.thread) === TIMER_EE) && expired(io.rw.thread)) {
      reg_timer(io.rw.thread) := TIMER_OFF
      exc_expire := true.B
    }
    when(io.ie) {
      reg_timer(io.rw.thread) := TIMER_IE
    }
    // capture interrupt and stop comparion
    val mtie = WireInit(false.B)
    when(io.rw.valid && (reg_timer(io.rw.thread) === TIMER_IE) && expired(io.rw.thread)) {
      reg_timer(io.rw.thread) := TIMER_OFF
      mtie := true.B
      reg_mtie(io.rw.thread) := true.B
    }
    // Only send interrupt to control if past or current cycle has timer
    // interrupt
    int_expire := reg_ie(io.rw.thread) && (reg_mtie(io.rw.thread) || mtie)
  }

  // Input handling
  // Every cycle, register GPI pins
  (reg_gpis zip io.gpio.in) map { case (l, r) => l := r }
  // Formerly in Chisel2: reg_gpis := io.gpio.in (chisel3#152)

  // External interrupt handling
  val int_ext = WireInit(false.B)
  if (conf.causes.contains(Causes.external_int)) {
    for (tid <- 0 until conf.threads) {
      // set interrupt as pending, only cleared once handled, and wake thread
      when(io.int_exts(tid)) {
        reg_msip(io.rw.thread) := true.B
        wake(tid) := true.B
      }
    }
    // Only send interrupt to control if past cycle has external
    // interrupt
    int_ext := reg_ie(io.rw.thread) && reg_msip(io.rw.thread)
  }

  // stats (not designed for performance)
  if (conf.stats) {
    when(io.cycle) {
      reg_cycle(io.rw.thread) := reg_cycle(io.rw.thread) + 1.U
    }
    when(io.instret) {
      reg_instret(io.rw.thread) := reg_instret(io.rw.thread) + 1.U
    }
  }

  // Privileged mode
  if (conf.privilegedMode) {
    when (io.exception) {
      // save current prv and ie
      reg_prv1 := reg_prv
      reg_ie1 := reg_ie
      // privileged mode with interrupts disabled
      reg_prv := 3.U(2.W)
      reg_ie := VecInit(Seq.fill(conf.threads) { false.B })
    } .elsewhen (io.sret) {
      // restore
      reg_prv := reg_prv1
      reg_ie := reg_ie1
    }
  } else {
    when (io.exception) {
      reg_ie := VecInit(Seq.fill(conf.threads) { false.B })
    }
  }

  io.rw.data_out := data_out
  io.slots := reg_slots
  io.tmodes := reg_tmodes
  if (conf.exceptions) {
    io.evecs := reg_evecs
  }
  io.expire := expired(io.rw.thread)
  io.host.to_host := reg_to_host

  (io.gpio.out zip reg_gpos) map { case (l, r) => l := r }
  // Formerly in Chisel2: io.gpio.out := reg_gpos (chisel3#152)

  io.imem_protection := reg_imem_protection
  io.dmem_protection := reg_dmem_protection
  io.exc_expire := exc_expire
  io.int_expire := int_expire
  io.int_ext := int_ext
  io.priv_fault := priv_fault


}
