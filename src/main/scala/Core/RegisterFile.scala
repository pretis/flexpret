/******************************************************************************
File: RegisterFile.scala
Description: Register file for all threads.
Author: Michael Zimmer <mzimmer@eecs.berkeley.edu>
Contributors: Edward Wang <edwardw@eecs.berkeley.edu>
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util.{Cat, log2Ceil, MuxLookup}
import Core.FlexpretConstants._
import chisel3.experimental.chiselName

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
  def apply(readPorts: Int = 2, writePorts: Int = 1)(implicit conf: FlexpretConfiguration): RegisterFile = new RegisterFile(conf.threads, readPorts=readPorts, writePorts=writePorts)
}

@chiselName
class RegisterFile(val threads: Int, val readPorts: Int = 2, val writePorts: Int = 1) extends Module {
  /* Number of bits. */
  val threadBits = log2Ceil(threads)
  /* Depth of the register file. */
  val regDepth = 32 * threads

  val io = IO(new Bundle {
    val read = Vec(readPorts, new RegisterFileReadIO(threadBits))
    val write = Vec(writePorts, new RegisterFileWriteIO(threadBits))
  })

  private def regfileAddress(thread: UInt, addr: UInt): UInt = {
    Mux(thread <= (threads - 1).U, Cat(thread, addr), 0.U)
  }
  val writeIndexes = io.write.map { port => regfileAddress(addr=port.addr, thread=port.thread) }

  // 1-cycle latency read and write
  // Note: default read-under-write behaviour is undefined!
  // Also define reading invalid threads to return DontCare.
  val regfile = SyncReadMem(regDepth, UInt(32.W))

  // Read ports
  io.read.foreach { readPort =>
    // Value read from regfile
    val readIndex = regfileAddress(addr=readPort.addr, thread=readPort.thread)

    val regfileRead = Mux(RegNext(readPort.thread) <= (threads - 1).U,
      regfile(readIndex),
      0.U
    )

    // Account for read-under-write.
    // If there was read-under-write, use the write port's value.
    // We also need to register the data and addresses since we are returning
    // last cycle's requests.
    val readUnderWrites = (writeIndexes zip io.write).map { case (writeIndex, writePort) =>
      (RegNext(writeIndex) -> RegNext(writePort.data))
    }

    val readIndexReg = RegNext(readIndex)
    readPort.data := MuxLookup(readIndexReg, regfileRead, Array(
      // Reading register 0
      (0.U -> 0.U)
    ) ++ readUnderWrites)
  }

  // Write ports
  (io.write zip writeIndexes).foreach { case (port, writeIndex) =>
    when(port.enable && port.addr =/= 0.U && port.thread <= (threads - 1).U) {
      regfile(writeIndex) := port.data
    }
  }
}
