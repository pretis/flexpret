/******************************************************************************
File: multiplier.scala:
Description:  Multi-stage multiplier.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Nicolas Hili (nicolas.hili@irt-saintexupery.com)
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

  val op1 = Mux(io.func === MUL_HU || io.func === DIV_LU || io.func === REM_LU, Cat(Bits(0, 1), io.op1).toSInt, Cat(io.op1(31), io.op1).toSInt)
  val op2 = Mux(io.func === MUL_HSU || io.func === MUL_HU || io.func === DIV_LU || io.func === REM_LU, Cat(Bits(0, 1), io.op2).toSInt, Cat(io.op2(31), io.op2).toSInt)
  val mul_result = Mux(io.func === REM_L || io.func === REM_LU, rem(op1, op2),
                      Mux(io.func === DIV_L || io.func === DIV_LU, div(op1, op2), op1 * op2));
  val result = Mux(io.func === MUL_L || io.func === DIV_L || io.func === DIV_LU || io.func === REM_L || io.func === REM_LU, mul_result(31, 0), mul_result(63, 32))

  // 2 cycle
  io.result := Reg(next = result)


  // FIXME: synthetisable signed rem operator not yet implemented
  def rem(dividend: Bits, divider: Bits) : Bits = {
    return Mux(io.func === REM_LU,
                divider_unsigned(dividend, divider, Bool(true)),
                dividend % divider);
  }

  // FIXME: synthetisable signed div operator not yet implemented
  def div(dividend : Bits, divider: Bits) : Bits = {
    return Mux(io.func === DIV_LU,
                divider_unsigned(dividend, divider, Bool(false)),
                dividend / divider);
  }

  def divider_unsigned(dividend : Bits, divider: Bits, isRemainder: Bool) : Bits = {
    var scaled_divider  = Cat(Bits(0,1), divider, Bits(0,31));
    var temp_remainder  = Cat(Bits(0,32), dividend);
    var temp_result     = Bits(0, 64);
    var quotient        = Bits(0,32);
    var remainder       = Bits(0,32);
    var temp            = Cat(Bits(1,1), Bits(0,32)); // FIXME: temp is a 33-bit value, otherwise, the last occurence in the for loop fails

    for (i <- 0 until 32) {
      temp_result = temp_remainder - scaled_divider;
      quotient = Mux(temp_result(63-i), quotient & (~temp(32,1)), quotient | temp(32,1));
      temp_remainder = Mux(temp_result(63-i), temp_remainder, temp_result);
      scaled_divider = scaled_divider >> UInt(1);

      temp = temp >> UInt(1);
    }
    remainder = temp_remainder(31,0);

    val result = Mux(isRemainder, remainder, quotient);
    return result;
  }
}
