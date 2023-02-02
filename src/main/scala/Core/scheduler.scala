/******************************************************************************
File: scheduler.scala
Description: Schedules thread-interleaving in pipeline using current values
in configuration registers (slots and tmodes).
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import chisel3._
import chisel3.util._

import FlexpretConstants._
import flexpret.core.FlexpretConfiguration

// Higher priorities to lower indices of sequence.
// (T, F, F, T) -> (T, F, F, F)
object priorityArbiter {
  def apply(request: Seq[Bool]) = {
    request(0) +: (1 until request.length).map(i => request(i) && !request.slice(0, i).foldLeft(false.B)(_ || _))
  }
}

object RRArbiterMaskMethod {
  def apply(request: Seq[Bool], lastGrantOH: Seq[Bool]) = {
    // For mask: all elements at indices > index of last grant are Bool(true), rest are Bool(false).
    val mask = false.B +: (1 until lastGrantOH.length).map(i => lastGrantOH.slice(0, i).foldLeft(false.B)(_ || _))
    // Mask the request sequence.
    val maskedRequest = (request, mask).zipped.map(_ && _)
    // Produce grant sequence for masked request sequence.
    val maskedGrant = priorityArbiter(maskedRequest)
    // Produce grant sequence for unmasked request sequence.
    val unmaskedGrant = priorityArbiter(request)

    // Use the masked grant vector unless the masked request vector is empty.
    // In this case, the unmasked grant vector is used ('wrap around')
    val useMaskedGrant = maskedRequest.foldLeft(false.B)(_ || _)
    (maskedGrant, unmaskedGrant).zipped.map(Mux(useMaskedGrant, _, _))
  }
}

// TODO XMOS-style: HA | SA
class Scheduler(implicit conf: FlexpretConfiguration) extends Module 
{
  val io = IO(new Bundle {
    val slots = Input(Vec(8, UInt(SLOT_WI.W)))
    val thread_modes = Input(Vec(conf.threads, UInt(TMODE_WI.W)))
    val thread = Output(UInt(conf.threadBits.W))
    val valid = Output(Bool())
  })

  def threadActive(i: UInt): Bool = { (io.thread_modes(i) === TMODE_HA) || (io.thread_modes(i) === TMODE_SA) }

  if(conf.threads == 1) {
    io.thread := 0.U
    io.valid := threadActive(0.U)
  } else if(conf.roundRobin) {
    // Round-robin thread counter.
    val currentThread = RegInit(0.U(conf.threadBits.W))
    currentThread := Mux(currentThread < (conf.threads - 1).U, currentThread + 1.U, 0.U)
    io.valid := threadActive(currentThread)
    io.thread := currentThread
  } else {
    // Find next slot that isn't disabled.
    // Implemented as round-robin arbiter using mask-based approach 
    // (Arbiters: Design Ideas and Coding Styles, Matt Weber).
    val slotOH = RegInit(VecInit(Seq.fill(8){false.B})) // OH = one-hot
    val slotRequest = io.slots.map(i => i =/= SLOT_D)
    val slotGrantOH = RRArbiterMaskMethod(slotRequest, slotOH)
    val slotGrantValid = slotGrantOH.foldLeft(false.B)(_ || _)
    val slotSelected = Mux1H(slotGrantOH, io.slots)
    
    // Find next SRRT that is active.
    val threadModeOH = RegInit(VecInit(Seq.fill(conf.threads){false.B}))
    val threadModeRequest = io.thread_modes.map(i => i === TMODE_SA)
    val threadModeGrantOH = RRArbiterMaskMethod(threadModeRequest, threadModeOH)
    val threadModeGrantValid = threadModeGrantOH.foldLeft(false.B)(_ || _)
    val threadSelected = OHToUInt(threadModeGrantOH)
        
    // Update states.
    io.thread := slotSelected(conf.threadBits-1,0)
    io.valid := false.B
    when(slotGrantValid) { 
      slotOH := slotGrantOH 
      when(slotSelected =/= SLOT_S && threadActive(slotSelected(conf.threadBits-1,0))) {
        io.thread := slotSelected(conf.threadBits,0)
        io.valid := true.B
      } .elsewhen(threadModeGrantValid) {
        threadModeOH := threadModeGrantOH 
        io.thread := threadSelected
        io.valid := true.B
      }
    }
    // printf(cf"io.slots = ${io.slots}, io.thread = ${io.thread}\n")
  }
}

