/******************************************************************************
File: divider.scala:
Description:  Multi-stage divider.
Author: Nicolas Hili (nicolas.hili@irt-saintexupery.com)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

class Divider(implicit conf: FlexpretConfiguration) extends Module {
  val io = new Bundle {
    val op1    = Bits(INPUT, 32)
    val op2    = Bits(INPUT, 32)
    val func   = UInt(INPUT, 4)
    val result = Bits(OUTPUT, 32)
  }

  val op1 = Mux(io.func === DIV_LU || io.func === REM_LU, Cat(Bits(0, 1), io.op1).toSInt, Cat(io.op1(31), io.op1).toSInt)
  val op2 = Mux(io.func === DIV_LU || io.func === REM_LU, Cat(Bits(0, 1), io.op2).toSInt, Cat(io.op2(31), io.op2).toSInt)
  val result = Mux(io.func === REM_L || io.func === REM_LU, rem(op1, op2), div(op1, op2));

  // 2 cycle
  io.result := Reg(next = result)

  def rem(dividend: SInt, divider: SInt) : Bits = {
    return divider_signed(dividend, divider, Bool(true));
  }

  def div(dividend : SInt, divider: SInt) : Bits = {
    return divider_signed(dividend, divider, Bool(false));
  }

  def divider_signed(dividend: SInt, divider: SInt, isRemainder: Bool) : Bits = {

    val sign_dividend = dividend < UInt(0);
    val sign_divider = divider < UInt(0);
    val sign_quotient = sign_dividend^sign_divider;
    val sign_remainder = sign_dividend;
    val sign_result = (isRemainder && sign_remainder) || (!isRemainder && sign_quotient);

    val result = divider_unsigned(
      Mux(sign_dividend, -dividend, dividend),
      Mux(sign_divider, -divider, divider),
      isRemainder);

    return Mux(sign_result,
      UInt(0)-result,
      result);
  }

  def divider_unsigned(dividend : Bits, divider: Bits, isRemainder: Bool) : Bits = {
    var scaled_divider  = Cat(Bits(0,1), divider, Bits(0,31));
    var temp_remainder  = Cat(Bits(0,32), dividend);
    var quotient        = Bits(0,32);
    var temp            = Cat(Bits(1,1), Bits(0,32));

    for (i <- 0 until 32) {
      val temp_result = temp_remainder - scaled_divider;
      quotient = Mux(temp_result(63-i), quotient & (~temp(32,1)), quotient | temp(32,1));
      temp_remainder = Mux(temp_result(63-i), temp_remainder, temp_result);
      scaled_divider = scaled_divider >> UInt(1);

      temp = temp >> UInt(1);
    }

    val result = Mux(isRemainder, temp_remainder(31,0), quotient);
    return result;
  }
}
