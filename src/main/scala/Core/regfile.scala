/******************************************************************************
File: regfile.scala
Description: Register file for all threads.
Author: Michael Zimmer <mzimmer@eecs.berkeley.edu>
Contributors: Edward Wang <edwardw@eecs.berkeley.edu>
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util.{Cat, log2Ceil}
import Core.FlexpretConfiguration
import Core.FlexpretConstants._

class RegisterFileReadIO(val threadBits: Int) extends Bundle {
  val thread = Input(UInt(threadBits.W))
  val addr = Input(UInt(REG_ADDR_BITS.W))
  val data = Output(UInt(32.W))
}

class RegisterFileWriteIO(val threadBits: Int) extends Bundle {
  val thread = Input(UInt(threadBits.W))
  val addr = Input(UInt(REG_ADDR_BITS.W))
  val data = Input(UInt(32.W))
  val enable = Input(Bool())
}

object RegisterFile {
  def apply()(implicit conf: FlexpretConfiguration): RegisterFile = new RegisterFile(conf.threads)
}

class RegisterFile(val threads: Int) extends Module {
  /* Number of bits. */
  val threadBits = log2Ceil(threads)
  /* Depth of the register file. */
  val regDepth = 32 * threads

  val io = IO(new Bundle {
    val rs1 = new RegisterFileReadIO(threadBits)
    val rs2 = new RegisterFileReadIO(threadBits)
    val rd = new RegisterFileWriteIO(threadBits)
  })

  private def regfileAddress(thread: UInt, addr: UInt): UInt = {
    Mux(thread <= (threads - 1).U, Cat(thread, addr), 0.U)
  }
  val writeIndex = regfileAddress(addr=io.rd.addr, thread=io.rd.thread)

  // 1-cycle latency read and write
  // Note: default read-under-write behaviour is undefined!
  // Also define reading invalid threads to return DontCare.
  val regfile = SyncReadMem(regDepth, UInt(32.W))
  val regfile_rs1_read = Mux(RegNext(io.rs1.thread) <= (threads - 1).U,
    regfile(regfileAddress(addr=io.rs1.addr, thread=io.rs1.thread)),
    0.U
  )
  val regfile_rs2_read = Mux(RegNext(io.rs2.thread) <= (threads - 1).U,
    regfile(regfileAddress(addr=io.rs2.addr, thread=io.rs2.thread)),
    0.U
  )
  val rs1_read = Mux(RegNext(writeIndex) === RegNext(io.rs1.addr), RegNext(io.rd.data), regfile_rs1_read)
  val rs2_read = Mux(RegNext(writeIndex) === RegNext(io.rs2.addr), RegNext(io.rd.data), regfile_rs2_read)

  // Read ports
  // We need to mux the registered addresses since we are returning
  // last cycle's requests.
  io.rs1.data := Mux(RegNext(io.rs1.addr) === 0.U, 0.U, rs1_read)
  io.rs2.data := Mux(RegNext(io.rs2.addr) === 0.U, 0.U, rs2_read)

  // Write port
  when(io.rd.enable && io.rd.addr =/= 0.U && io.rd.thread <= (threads - 1).U) {
    regfile(writeIndex) := io.rd.data
  }
}
