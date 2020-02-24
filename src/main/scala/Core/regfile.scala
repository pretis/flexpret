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

  val writeIndex = Cat(io.rd.addr, io.rd.thread)

  // 1-cycle latency read and write
  // Note: default read-under-write behaviour is undefined!
  val regfile = SyncReadMem(conf.regDepth, UInt(32.W))
  val rs1_read = Mux(RegNext(writeIndex) === RegNext(io.rs1.addr), RegNext(io.rd.data), regfile(Cat(io.rs1.addr, io.rs1.thread)))
  val rs2_read = Mux(RegNext(writeIndex) === RegNext(io.rs2.addr), RegNext(io.rd.data), regfile(Cat(io.rs2.addr, io.rs2.thread)))

  // Read ports
  // We need to mux the registered addresses since we are returning
  // last cycle's requests.
  io.rs1.data := Mux(RegNext(io.rs1.addr) === 0.U, 0.U, rs1_read)
  io.rs2.data := Mux(RegNext(io.rs2.addr) === 0.U, 0.U, rs2_read)

  // Write port
  when(io.rd.enable && io.rd.addr =/= 0.U) {
    regfile(writeIndex) := io.rd.data
  }
}
  
