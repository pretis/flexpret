/******************************************************************************
File: regfile.scala
Description: Register file for all threads.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util.Cat
import Core.FlexpretConfiguration
import Core.FlexpretConstants._

class RegisterFile(implicit conf: FlexpretConfiguration) extends Module {
  val io = IO(new Bundle {
    val rs1 = new Bundle {
      val thread = Input(UInt(conf.threadBits.W))
      val addr = Input(UInt(REG_ADDR_BITS.W))
      val data = Output(UInt(32.W))
    }
    val rs2 = new Bundle {
      val thread = Input(UInt(conf.threadBits.W))
      val addr = Input(UInt(REG_ADDR_BITS.W))
      val data = Output(UInt(32.W))
    }
    val rd = new Bundle {
      val thread = Input(UInt(conf.threadBits.W))
      val addr = Input(UInt(REG_ADDR_BITS.W))
      val data = Input(UInt(32.W))
      val enable = Input(Bool())
    }
  })

  // 1-cycle latency read and write
  val regfile = SyncReadMem(conf.regDepth, UInt(32.W))

  // Read ports
  // We need to mux the registered addresses since we are returning
  // last cycle's requests.
  io.rs1.data := Mux(RegNext(io.rs1.addr) === 0.U, 0.U, regfile(Cat(io.rs1.addr, io.rs1.thread)))
  io.rs2.data := Mux(RegNext(io.rs2.addr) === 0.U, 0.U, regfile(Cat(io.rs2.addr, io.rs2.thread)))

  // Write port
  when(io.rd.enable && io.rd.addr =/= 0.U) {
    regfile(Cat(io.rd.addr, io.rd.thread)) := io.rd.data
  }
}
  
