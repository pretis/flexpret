/******************************************************************************
multiplier.scala:
  Multi-stage multiplier.
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

class Multiplier(mulStages: Int) extends Module {
  val io = new Bundle {
    val op1    = Bits(INPUT, XPRLEN)
    val op2    = Bits(INPUT, XPRLEN)
    val func   = UInt(INPUT, 4)
    val result = Bits(OUTPUT, XPRLEN)
  }

  val op1 = Mux(io.func === ALU_MULHU, Cat(Bits(0, 1), io.op1).toSInt, Cat(io.op1(31), io.op1).toSInt)
  val op2 = Mux(io.func === ALU_MULHSU || io.func === ALU_MULHU, Cat(Bits(0, 1), io.op2).toSInt, Cat(io.op2(31), io.op2).toSInt)
  val mul_result = op1 * op2
  val result = Mux(io.func === ALU_MUL, mul_result(31, 0).toUInt, mul_result(63, 32).toUInt)

  if(mulStages == 1) {
    io.result := result
  } else if(mulStages == 2) {
    io.result := Reg(next = result)
  } else if(mulStages == 3) {
    io.result := Reg(next = Reg(next = result))
  }

}

}
