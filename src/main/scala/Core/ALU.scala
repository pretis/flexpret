/******************************************************************************
File: ALU.scala
Description: ALU
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util._

/**
 * ALU operation types.
 */
object ALUTypes extends ChiselEnum {
  val Add = Value
  val Sub = Value
  val ShiftLeft = Value
  val ShiftRightArithmetic = Value
  val ShiftRightLogical = Value
  val And = Value
  val Or = Value
  val Xor = Value
  val LessThanSigned = Value
  val LessThanUnsigned = Value

  val Unknown = BitPat("b" + "?" * ALUTypes.getWidth)

  // Syntactic sugar
  def unapply(x: UInt): Option[ALUTypes.Type] = Some(ALUTypes(x))
}

object ExampleEnum extends ChiselEnum {
  val Foo, Bar = Value
}

/**
 * Helpful BitPat aliases for ALU types. For use in a BitPat-based decoder.
 */
object ALUBitPats {
  // Work around Chisel3 #1871
  def toBitPat(aluLit: ALUTypes.Type) = BitPat(aluLit.litValue.U(ALUTypes.getWidth.W))

  val ALU_X = ALUTypes.Unknown
  val ALU_ADD = toBitPat(ALUTypes.Add)
  val ALU_SUB = toBitPat(ALUTypes.Sub)
  val ALU_SL = toBitPat(ALUTypes.ShiftLeft)
  val ALU_SRA = toBitPat(ALUTypes.ShiftRightArithmetic)
  val ALU_SRL = toBitPat(ALUTypes.ShiftRightLogical)
  val ALU_AND = toBitPat(ALUTypes.And)
  val ALU_OR = toBitPat(ALUTypes.Or)
  val ALU_XOR = toBitPat(ALUTypes.Xor)
  val ALU_LTS = toBitPat(ALUTypes.LessThanSigned)
  val ALU_LTU = toBitPat(ALUTypes.LessThanUnsigned)
}

class ALU extends Module {
  val io = IO(new Bundle {
    val op1    = Input(UInt(32.W))
    val op2    = Input(UInt(32.W))
    val shift  = Input(UInt(5.W)) // used only for io.shifting operations. SRLI requires 5 bits.
    val func   = Input(ALUTypes())
    val result = Output(UInt(32.W))
  })

  val dontCare = Wire(UInt(32.W))
  dontCare := DontCare

  import ALUTypes._
  io.result := MuxLookup(io.func.asUInt, dontCare, Seq[(UInt, UInt)](
    Add.asUInt -> (io.op1 + io.op2),
    Sub.asUInt -> (io.op1 - io.op2),
    ShiftLeft.asUInt -> (io.op1 << io.shift)(31, 0),
    ShiftRightArithmetic.asUInt -> (io.op1.asSInt >> io.shift).asUInt,
    ShiftRightLogical.asUInt -> (io.op1 >> io.shift),
    And.asUInt -> (io.op1 & io.op2),
    Or.asUInt -> (io.op1 | io.op2),
    Xor.asUInt -> (io.op1 ^ io.op2),
    LessThanSigned.asUInt -> (io.op1.asSInt < io.op2.asSInt).asUInt,
    LessThanUnsigned.asUInt -> (io.op1 < io.op2),

  ))
}

