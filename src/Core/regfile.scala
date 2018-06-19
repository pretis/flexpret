/******************************************************************************
File: regfile.scala
Description: Register file for all threads.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

class RegisterFile(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new Bundle {
    val rs1 = new Bundle {
      val thread = UInt(INPUT, conf.threadBits)
      val addr = UInt(INPUT, REG_ADDR_BITS)
      val data = Bits(OUTPUT, 32)
    }
    val rs2 = new Bundle {
      val thread = UInt(INPUT, conf.threadBits)
      val addr = UInt(INPUT, REG_ADDR_BITS)
      val data = Bits(OUTPUT, 32)
    }
    val rd = new Bundle {
      val thread = UInt(INPUT, conf.threadBits)
      val addr = UInt(INPUT, REG_ADDR_BITS)
      val data = Bits(INPUT, 32)
      val enable = Bool(INPUT)
    }
  }

  val regfile = Mem(Bits(width = 32), conf.regDepth, true)

  // infer sequential read
  val dout1 = Reg(Bits(width = 32))
  val dout2 = Reg(Bits(width = 32))
  io.rs1.data := dout1
  io.rs2.data := dout2

  // read ports
  dout1 := Mux(io.rs1.addr === UInt(0), Bits(0),
               regfile(Cat(io.rs1.addr, io.rs1.thread)))
  dout2 := Mux(io.rs2.addr === UInt(0), Bits(0),
               regfile(Cat(io.rs2.addr, io.rs2.thread)))

  // write port
  when(io.rd.enable) {
    regfile(Cat(io.rd.addr, io.rd.thread)) := io.rd.data
  }
}
  
