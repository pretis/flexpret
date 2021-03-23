/******************************************************************************
Description: Test for a simple core.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import org.scalatest._

import chisel3._

import chiseltest._
import chiseltest.experimental.TestOptionBuilder._

import Core.FlexpretConstants._

import flexpret.core._
import Core.Datapath

/**
 * Simulate an instruction memory module on a InstMemCoreIO.
 * @param prog Program memory as Chisel hex strings. Example:
 * val prog: Seq[String] = scala.collection.immutable.Vector(
 *   "h00100313", // li t1,1
      "hcc431073", // csrw 0xcc4,t1
      "h00000013", // nop
      "hcc401073", // csrw 0xcc4,zero
      "h00000013", // nop
      "hfedff06f", // j 0
    )
 * @param defaultInstr Default instruction if out of bounds (as a Chisel hex str).
 * @param startAddr imem entry to start instructions at (default 0).
 *                  NOTE: this is not a byte address! e.g. 1 would correspond
 *                  to instruction at PC+4.
 */
class ImemSimulator(
  val prog: Seq[String],
  val defaultInstr: String,
  val clk: Clock, val memIO: InstMemCoreIO,
  val startAddr: Int = 0) {
  require(startAddr >= 0, "Start must be positive")

  def sim(cycles: Int): Unit = {
    var i = 0
    while (i < cycles) { i += 1;
      val addr = memIO.r.addr.peek().litValue.toInt
      val enabled = memIO.r.enable.peek().litValue
      clk.step()

      val imemData = prog.lift.apply(addr - startAddr).getOrElse(defaultInstr)
      memIO.r.data_out.poke(imemData.U)
    }
  }
}
