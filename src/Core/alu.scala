/******************************************************************************
alu.scala:
  Arithmetic unit (excluding multiplier).
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

class Alu(conf: CoreConfig) extends Module {
  val io = new Bundle {
    val op1    = Bits(INPUT, XPRLEN)
    val op2    = Bits(INPUT, XPRLEN)
    val func   = UInt(INPUT, 4)
    val result = Bits(OUTPUT, XPRLEN)
  }

  val op1   = io.op1.toUInt
  val op2   = io.op2.toUInt
  val shamt = io.op2(4,0).toUInt
  val result = MuxCase(op2, Array(
    (io.func === ALU_ADD)    -> (op1 + op2).toUInt,
    (io.func === ALU_SUB)    -> (op1 - op2).toUInt,
    (io.func === ALU_AND)    -> (op1 & op2).toUInt,
    (io.func === ALU_OR)     -> (op1 | op2).toUInt,
    (io.func === ALU_XOR)    -> (op1 ^ op2).toUInt,
    (io.func === ALU_SLT)    -> (op1.toSInt < op2.toSInt).toUInt,
    (io.func === ALU_SLTU)   -> (op1 < op2).toUInt,
    (io.func === ALU_SLL)    -> ((op1 << shamt)(XPRLEN-1, 0)).toUInt,
    (io.func === ALU_SRA)    -> (op1.toSInt >> shamt).toUInt,
    (io.func === ALU_SRL)    -> (op1 >> shamt).toUInt,
    (io.func === ALU_COPY_2) -> op2
  ))

  io.result := result

}

}
