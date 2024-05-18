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

class CSR(confHash: UInt, implicit val conf: FlexpretConfiguration) extends Module {
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
    val mepcs = Output(Vec(conf.threads, UInt(32.W)))
    // timing
    val sleep_du = Input(Bool())
    val sleep_wu = Input(Bool())
    val ie = Input(Bool()) // valid IE inst
    val ee = Input(Bool()) // valid EE inst
    val expire_du = Output(Vec(conf.threads, Bool()))
    val expire_wu = Output(Vec(conf.threads, Bool()))
    val expire_ie = Output(Vec(conf.threads, Bool()))
    val expire_ee = Output(Vec(conf.threads, Bool()))

    val timer_expire_du_wu = Output(Vec(conf.threads, Bool()))

    val if_tid = Input(UInt(conf.threadBits.W))
    val dec_tid = Input(UInt(conf.threadBits.W))
    // Return from exception
    val mret = Input(Bool())
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
    val int_ext = Output(Bool()) // external interrupt
    val priv_fault = Output(Bool()) // CSR permission
  })

  // ************************************************************
  // CSR state

  // thread scheduler
  // val reg_slots = RegInit(VecInit(conf.initialSlots.map(i => i).toSeq)) // i => i since they are already UInts
  val reg_slots = RegInit(VecInit(conf.initialSlots.toSeq))
  val reg_tmodes = RegInit(VecInit(conf.initialTmodes.toSeq))
  // exception handling
  val reg_evecs = Reg(Vec(conf.threads, UInt()))
  val reg_mepcs = Reg(Vec(conf.threads, UInt())) // RO?

  val reg_causes = Reg(Vec(conf.threads, UInt())) // RO
  val reg_sup0 = Reg(Vec(conf.threads, UInt()))

  // I/O
  val regs_to_host = RegInit(VecInit(Seq.fill(conf.threads) { 0.U(32.W) }))
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
  val reg_in_interrupt = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))

  // timing instructions
  val reg_time = RegInit(0.U(64.W)) // RO, less bits if !conf.stats
  val reg_compare_du_wu = Reg(Vec(conf.threads, UInt(conf.timeBits.W)))
  val reg_compare_ie_ee = Reg(Vec(conf.threads, UInt(conf.timeBits.W)))

  // Denotes whether the `reg_compare_du_wu` is set for DU or WU (or off)
  val reg_compare_du_wu_type = RegInit(VecInit(Seq.fill(conf.threads) { TIMER_OFF }))

  // Denotes whether the `reg_compare_ie_ee` is set for IE or EE (or off)
  val reg_compare_ie_ee_type = RegInit(VecInit(Seq.fill(conf.threads) { TIMER_OFF }))

  // for reading of status CSR
  val status = Wire(Vec(conf.threads, UInt()))
  for (tid <- 0 until conf.threads) {
    status(tid) := Cat(1.U(1.W), 0.U(4.W), reg_mtie(tid), 0.U(20.W), reg_prv1(tid), reg_ie1(tid), reg_prv(tid), reg_ie(tid), reg_msip(tid), reg_in_interrupt(tid), 0.U(2.W))
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

  // Check whether the write does not make any alterations; i.e. it is a fake write
  // This is the case if the CSRRS (sets bits) or CSRRC (clears bits) provide
  // bitmasks that are zero
  // This allows non-priviledged mode for instructions that do not alter the CSRs
  val fake_write = WireInit(false.B)
  if (conf.privilegedMode) {
    fake_write := MuxLookup(io.rw.csr_type, false.B, Array(
      CSR_S -> (io.rw.data_in === 0.U),
      CSR_C -> (io.rw.data_in === 0.U),
      CSR_W -> false.B
    ))
  }

  // check permission (if privileged)
  val priv_fault = WireInit(false.B) // default value
  if (conf.privilegedMode) {
    val addr_read_only = io.rw.addr(11, 10) === 3.U // 0xC__ suggests read-only.
    val addr_no_priv = (io.rw.addr(9, 8) =/= 0.U) && (reg_prv(io.rw.thread) === 0.U(2.W))
    when((io.rw.write && !fake_write) && (addr_read_only || addr_no_priv)) {
      priv_fault := true.B
    }
  }

  // ************************************************************
  // CSR write (may be later over-written)

  val write = io.rw.write && !priv_fault && !io.kill && !fake_write
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
    if (conf.delayUntil) {
      when(compare_addr(CSRs.compare_du_wu)) {
        reg_compare_du_wu(io.rw.thread) := data_in(conf.timeBits - 1, 0)
        reg_compare_du_wu_type(io.rw.thread) := TIMER_OFF
      }
    }
    if (conf.interruptExpire) {
      when(compare_addr(CSRs.compare_ie_ee)) {
        reg_compare_ie_ee(io.rw.thread) := data_in(conf.timeBits - 1, 0)
        reg_compare_ie_ee_type(io.rw.thread) := TIMER_OFF
      }
    }
    for (tid <- 0 until conf.threads) {
      when(compare_addr(CSRs.tohost0 + tid)) {
        regs_to_host(tid) := data_in
      }
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
      reg_in_interrupt(io.rw.thread) := data_in(2).asBool
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
    when(compare_addr(CSRs.mepc)) {
      data_out := reg_mepcs(io.rw.thread)
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
  for (tid <- 0 until conf.threads) {
    when(compare_addr(CSRs.tohost0 + tid)) {
      data_out := regs_to_host(tid)
    }
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

  when(compare_addr(CSRs.core_id)) {
    data_out := conf.coreId.U
  }

  when(compare_addr(CSRs.confHash)) {
    data_out := confHash
  }

  // ************************************************************
  // State update (override any CSR write)

  // Thread scheduler
  // TODO: need to sleep at end exe or wait a cycle?
  when(io.sleep_du || io.sleep_wu) {
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

  // Implement HW lock
  if (conf.hwLock) {
    val lock = Module(new Lock()).io
    lock.driveDefaultsFlipped()

    when (write && compare_addr(CSRs.hwlock)) {
      lock.valid := true.B
      lock.tid := io.rw.thread
      data_out := lock.grant
      // When "CSRRW rd, hwlock, 1", acquire the lock.
      when(io.rw.data_in === 1.U) {
        lock.acquire := true.B
      }
      // When "CSRRW rd, hwlock, 0", acquire the lock.
      .elsewhen (io.rw.data_in === 0.U) {
        lock.acquire := false.B
        // If for some reason, the lock cannot be released,
        // raise an exception.
        assert(lock.grant, cf"thread-${io.rw.thread} could not release lock")
      }.otherwise {
        assert(false.B)
      }
    }
  }

  // exception handling
  if (conf.exceptions) {
    // The work on exception handling with different priviledge modes
    // can be handled here; for now just the machine exceptions are handled
    when(io.exception) {
      when (reg_compare_du_wu_type(io.rw.thread) === TIMER_WU) {
        // If we have exception and mret at the same time, it means the interrupt
        // signal probably stayed on for the duration of the interrupt. In this
        // case we do not update the mepcs; we just run another interrupt with the
        // same mepcs register.
        when (!io.mret) {
          // Wait until needs to return to the next instruction because it shall
          // be woken up when an exception occurs
          reg_mepcs(io.rw.thread) := io.epc + 4.U
        }

        // It also needs to turn off its timer, because the instruction is done
        reg_compare_du_wu_type(io.rw.thread) := TIMER_OFF
      }.otherwise {
        
        // If we have exception and mret at the same time, it means the interrupt
        // signal probably stayed on for the duration of the interrupt. In this
        // case we do not update the mepcs; we just run another interrupt with the
        // same mepcs register.
        when (!io.mret) {
          // If the thread is in delay until (DU) instruction, we want to return
          // to the same PC. That goes for the normal case as well.
          reg_mepcs(io.rw.thread) := io.epc
        }
      }
      reg_causes(io.rw.thread) := io.cause
      reg_in_interrupt(io.rw.thread) := true.B
    } .elsewhen (io.mret) {
      // Clear pending interrupt
      reg_msip(io.rw.thread) := false.B
      reg_in_interrupt(io.rw.thread) := false.B
    }
  }

  // update time every cycle
  if (conf.getTime) {
    reg_time := reg_time + conf.timeInc.U
  }

  /**
   * Keep track of whether any of the timing instructions have had their timers
   * expired. Delay until (DU) and wait until (WU) share their compare
   * register (`reg_compare_du_wu`). Interrupt on expire (IE) and
   * exception on expire (EE) share their compare register (`reg_compare_ie_ee`).
   * 
   * This means a thread cannot run DU/WU simultaneously. The same goes for IE/EE.
   * It can, however, run a combination of DU/WU and IE/EE simultaneously.
   * 
   */
  val expired_du = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val expired_wu = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val expired_ie = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))
  val expired_ee = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))
  
  // Constructing `expired_ie` requires a bit more logic than the others
  val expired_ie_part = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))

  /**
   * Is high if `reg_time` >= `reg_compare_du_wu` regardsless of whether a DU/WU
   * instruction is running.
   * 
   * This signal is necessary to handle the case where the user sets
   * `reg_compare_du_wu` < `reg_time`. (I.e., a DU/WU that already has expired.)
   * In this case, the instruction should function as a nop.
   * 
   */
  val reg_compare_expired_du_wu = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))
    
  // unless conf.roundRobin, use comparator for each thread
  // otherwise wake precision limited by number of comparators
  if (conf.delayUntil) {
    for (tid <- 0 until conf.threads) {      
      reg_compare_expired_du_wu(tid) := ((reg_time(conf.timeBits - 1, 0) - reg_compare_du_wu(tid)) (conf.timeBits - 1) === 0.U(1.W))

      when (reg_compare_du_wu_type(tid) === TIMER_DU) {
        expired_du(tid) := reg_compare_expired_du_wu(tid)
      }

      when (reg_compare_du_wu_type(tid) === TIMER_WU) {
        expired_wu(tid) := reg_compare_expired_du_wu(tid)
      }

      if (conf.roundRobin) {
        when(io.rw.thread =/= tid.U) {
          expired_du(tid) := false.B
          expired_wu(tid) := false.B
        }
      }
    }
  }

  val reg_compare_expired_ie_ee = WireInit(VecInit(Seq.fill(conf.threads) { false.B }))

  if (conf.interruptExpire) {
    for (tid <- 0 until conf.threads) {
      reg_compare_expired_ie_ee(tid) := ((reg_time(conf.timeBits - 1, 0) - reg_compare_ie_ee(tid)) (conf.timeBits - 1) === 0.U(1.W))
      
      // Each value compared to current time
      when (reg_compare_ie_ee_type(io.rw.thread) === TIMER_EE) {
        expired_ee(tid) := reg_compare_expired_ie_ee(tid)
      }
      
      when (reg_compare_ie_ee_type(io.rw.thread) === TIMER_IE) {
        expired_ie_part(tid) := reg_compare_expired_ie_ee(tid)
      }

      if (conf.roundRobin) {
        when(io.rw.thread =/= tid.U) {
          expired_ie(tid) := false.B
          expired_ee(tid) := false.B
        }
      }
    }
  }

  // compare value should already be set
  if (conf.delayUntil) {
    // DU/WU instruction sleeps thread and sets timer mode
    when (io.sleep_du) {
      reg_compare_du_wu_type(io.rw.thread) := TIMER_DU
    }
    when (io.sleep_wu) {
      reg_compare_du_wu_type(io.rw.thread) := TIMER_WU
    }

    if (conf.interruptExpire) {
      when(io.int_ext || expired_ie_part(io.rw.thread) || expired_ee(io.rw.thread)) {
        wake(io.rw.thread) := true.B
      }
    }

    // Check each thread for expiration and wake
    for (tid <- 0 until conf.threads) {
      when(expired_du(tid) || expired_wu(tid)) {
        wake(tid) := true.B
        
        val thread_active = (reg_tmodes(io.if_tid) === TMODE_HA) || (reg_tmodes(io.if_tid) === TMODE_SA)
        when (thread_active) {
          reg_compare_du_wu_type(io.if_tid) := TIMER_OFF
        }
      }
    }
  }

  if (conf.interruptExpire) {
    // IE/EE instruction sets timer mode
    when(io.ie) {
      reg_compare_ie_ee_type(io.rw.thread) := TIMER_IE
    }
    when(io.ee) {
      reg_compare_ie_ee_type(io.rw.thread) := TIMER_EE
    }

    // send exception, but may not have priority
    when(reg_compare_ie_ee_type(io.rw.thread) === TIMER_EE && expired_ee(io.rw.thread)) {
      reg_compare_ie_ee_type(io.rw.thread) := TIMER_OFF
    }
    // capture interrupt and stop comparion
    val mtie = WireInit(false.B)
    when(reg_compare_ie_ee_type(io.rw.thread) === TIMER_IE && expired_ie_part(io.rw.thread)) {
      reg_compare_ie_ee_type(io.rw.thread) := TIMER_OFF
      mtie := true.B
      reg_mtie(io.rw.thread) := true.B
    }
    // Only send interrupt to control if past or current cycle has timer
    // interrupt
    expired_ie(io.rw.thread) := reg_ie(io.rw.thread) && (reg_mtie(io.rw.thread) || mtie)
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
        reg_msip(tid) := true.B
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
      reg_prv := VecInit(Seq.fill(conf.threads) { 3.U(2.W) })
      reg_ie := VecInit(Seq.fill(conf.threads) { false.B })
    } .elsewhen (io.mret) {
      // restore
      // Note: mret might not be corret; perhaps another priviledge level
      //       must be implemented
      reg_prv := reg_prv1
      reg_ie := reg_ie1
      reg_in_interrupt(io.rw.thread) := false.B
    }
  } else {
    when (io.exception) {
      when (expired_ie(io.rw.thread) || expired_ee(io.rw.thread) || io.int_exts(io.rw.thread)) {
        // Setting everything to zero will break IE/EE instructions for other
        // threads
        reg_ie(io.rw.thread) := false.B
      }.otherwise {
        reg_ie := VecInit(Seq.fill(conf.threads) { false.B })
      }
    }
  }

  io.rw.data_out := data_out
  io.slots := reg_slots
  io.tmodes := reg_tmodes
  if (conf.exceptions) {
    io.evecs := reg_evecs
    io.mepcs  := reg_mepcs
  }
  
  io.expire_du := expired_du
  io.expire_wu := expired_wu
  io.expire_ie := expired_ie
  io.expire_ee := expired_ee
  io.timer_expire_du_wu := reg_compare_expired_du_wu

  for (tid <- 0 until conf.threads) {
    io.host.to_host(tid) := regs_to_host(tid)
  }

  (io.gpio.out zip reg_gpos) map { case (l, r) => l := r }
  // Formerly in Chisel2: io.gpio.out := reg_gpos (chisel3#152)

  io.imem_protection := reg_imem_protection
  io.dmem_protection := reg_dmem_protection
  io.int_ext := int_ext
  io.priv_fault := priv_fault
}
