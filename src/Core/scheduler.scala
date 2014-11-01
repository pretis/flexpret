/******************************************************************************
File: scheduler.scala
Description: Schedules thread-interleaving in pipeline using current values
in configuration registers (slots and tmodes).
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._
import FlexpretConfiguration._

// Higher priorities to lower indices of sequence.
// (T, F, F, T) -> (T, F, F, F)
object priorityArbiter {
  def apply(request: Seq[Bool]) = {
    request(0) +: (1 until request.length).map(i => request(i) && !request.slice(0, i).foldLeft(Bool(false))(_ || _))
  }
}

object RRArbiterMaskMethod {
  def apply(request: Seq[Bool], lastGrantOH: Seq[Bool]) = {
    // For mask: all elements at indices > index of last grant are Bool(true), rest are Bool(false).
    val mask = Bool(false) +: (1 until lastGrantOH.length).map(i => lastGrantOH.slice(0, i).foldLeft(Bool(false))(_ || _))
    // Mask the request sequence.
    val maskedRequest = (request, mask).zipped.map(_ && _)
    // Produce grant sequence for masked request sequence.
    val maskedGrant = priorityArbiter(maskedRequest)
    // Produce grant sequence for unmasked request sequence.
    val unmaskedGrant = priorityArbiter(request)

    // Use the masked grant vector unless the masked request vector is empty.
    // In this case, the unmasked grant vector is used ('wrap around')
    val useMaskedGrant = maskedRequest.foldLeft(Bool(false))(_ || _)
    (maskedGrant, unmaskedGrant).zipped.map(Mux(useMaskedGrant, _, _))
  }
}

class Scheduler(implicit conf: FlexpretConfiguration) extends Module 
{
  val io = new Bundle {
    val slots = Vec.fill(8) { UInt(INPUT, 4) }
    val thread_modes = Vec.fill(conf.threads) { UInt(INPUT, 2) }
    val thread = UInt(OUTPUT, conf.threadBits)
    val valid = Bool(OUTPUT)
  }
  if(conf.threads == 1) {
    io.thread := UInt(0)
    io.valid := Mux((io.thread_modes(0) === TMODE_HA) || (io.thread_modes(0) === TMODE_SA), Bool(true), Bool(false))
  } else {
    // Find next slot that isn't disabled.
    // Implemented as round-robin arbiter using mask-based approach 
    // (Arbiters: Design Ideas and Coding Styles, Matt Weber).
    val slotOH = Vec.fill(8) { Reg(init = Bool(false)) }
    val slotRequest = io.slots.map(i => i != UInt(15, 4)) //SCH_D
    val slotGrantOH = RRArbiterMaskMethod(slotRequest, slotOH)
    val slotGrantValid = slotGrantOH.foldLeft(Bool(false))(_ || _)
    val slotSelected = Mux1H(slotGrantOH, io.slots)
    
    // Find next SRRT that is active.
    val threadModeOH = Vec.fill(conf.threads) { Reg(init = Bool(false))}
    val threadModeRequest = io.thread_modes.map(i => i === UInt(2,2)) //TMODE_SA
    val threadModeGrantOH = RRArbiterMaskMethod(threadModeRequest, threadModeOH)
    val threadModeGrantValid = threadModeGrantOH.foldLeft(Bool(false))(_ || _)
    val threadSelected = OHToUInt(threadModeGrantOH)
        
    // Update states (vec := vec?)
    io.thread := slotSelected(conf.threadBits-1,0)
    io.valid := Bool(false)
    when(slotGrantValid) { 
      slotOH := slotGrantOH 
      when(slotSelected != UInt(14, 4) && io.thread_modes(slotSelected(conf.threadBits-1,0))(0) === UInt(0, 1)) {
        io.thread := slotSelected(conf.threadBits,0)
        io.valid := Bool(true)
      } .elsewhen(threadModeGrantValid) {
        threadModeOH := threadModeGrantOH 
        io.thread := threadSelected
        io.valid := Bool(true)
      }
    }
  }
}

