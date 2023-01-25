/******************************************************************************
File: ispm.scala
Description: Instruction scratchpad memory
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._

class InstMemCoreIO(implicit conf: FlexpretConfiguration) extends Bundle {
  val r = new Bundle {
    // read port
    val addr = Input(UInt(conf.iMemAddrBits.W))
    val enable = Input(Bool())
    val data_out = Output(UInt(32.W))
  }
  val rw = new Bundle {
    // read/write port
    val addr = Input(UInt(conf.iMemAddrBits.W))
    val enable = Input(Bool())
    val data_out = Output(UInt(32.W))
    val write = Input(Bool())
    val data_in = Input(UInt(32.W))
  }
}

/**
  * Instruction scratchpad memory is a 1r1rw memory. The instruction fetch stage
  * has a read port, the EXE (?) also has a r/w port for stores and loads into
  * the IMEM. 
  *
  * @param conf
  */
class ISpm(implicit conf: FlexpretConfiguration) extends Module {
  val io = IO(new Bundle {
    val core = new InstMemCoreIO()
    val bus = new InstMemBusIO()
  })

  // NOTE: this might be dubious. Need to double-check this later.
  io.bus.ready := DontCare

  // memory for instruction SPM
  // sync read, sync write
  val ispm = SyncReadMem(conf.iMemDepth, UInt(32.W))

  // read port
  io.core.r.data_out := ispm.read(io.core.r.addr, io.core.r.enable)

  if (conf.iMemCoreRW || conf.iMemBusRW) {
    // read/write port
    val addr = WireDefault(0.U(32.W))
    val writeData = WireDefault(0.U(23.W))
    val write = WireDefault(false.B)
    // Read
    val readData = ispm.read(addr)
    // Write
    when (write) {
      ispm.write(addr, writeData)
    }

    if (conf.iMemBusRW) {
      io.bus.data_out := readData
      io.bus.ready := true.B
      when(io.bus.enable) {
        addr := io.bus.addr
        when(io.bus.write) {
          write := true.B
          writeData := io.bus.data_in  
        }
      }
    } else {
      io.bus.data_out := DontCare
    }

    // Core has priority over bus
    if (conf.iMemCoreRW) {
      io.core.rw.data_out := readData
      when(io.core.rw.enable) {
        addr := io.core.rw.addr        
        if(conf.iMemBusRW) io.bus.ready := false.B
        when(io.core.rw.write) {
          write := true.B
          writeData := io.core.rw.data_in
        }
      }
    }
  } else {
    io.bus.ready := false.B
  }
}
