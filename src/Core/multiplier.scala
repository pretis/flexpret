/******************************************************************************
File: multiplier.scala:
Description:  Multi-stage multiplier.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

class Multiplier(implicit conf: FlexpretConfiguration) extends Module {
  val io = new Bundle {
    val op1    = Bits(INPUT, 32)
    val op2    = Bits(INPUT, 32)
    val func   = UInt(INPUT, 4)
    val result = Bits(OUTPUT, 32)
  }
  
  val op1 = Mux(io.func === MUL_HU, Cat(Bits(0, 1), io.op1).toSInt, Cat(io.op1(31), io.op1).toSInt)
  val op2 = Mux(io.func === MUL_HSU || io.func === MUL_HU, Cat(Bits(0, 1), io.op2).toSInt, Cat(io.op2(31), io.op2).toSInt)
  val mul_result = op1 * op2
  val result = Mux(io.func === MUL_L, mul_result(31, 0), mul_result(63, 32))

  // 2 cycle
  io.result := Reg(next = result)

}

