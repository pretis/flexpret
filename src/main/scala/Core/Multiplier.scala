/******************************************************************************
File: Multiplier.scala:
Description:  Multi-stage multiplier.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util._

import Core.FlexpretConstants._

class Multiplier extends Module {
  val io = IO(new Bundle {
    val op1    = Input(UInt(32.W))
    val op2    = Input(UInt(32.W))
    val func   = Input(UInt(4.W))
    val result = Output(UInt(32.W))
  })

  val op1 = Mux(io.func === MUL_HU, Cat(0.U(1.W), io.op1).asSInt, Cat(io.op1(31), io.op1).asSInt)
  val op2 = Mux(io.func === MUL_HSU || io.func === MUL_HU, Cat(0.U(1.W), io.op2).asSInt, Cat(io.op2(31), io.op2).asSInt)
  val mul_result = op1 * op2
  val result = Mux(io.func === MUL_L, mul_result(31, 0), mul_result(63, 32))

  // 2 cycle
  io.result := RegNext(result)
}

