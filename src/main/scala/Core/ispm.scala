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

  override def cloneType = (new InstMemCoreIO).asInstanceOf[this.type]
}

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
    val busRwPort = ispm(io.bus.addr)

    if (conf.iMemBusRW) {
      io.bus.data_out := busRwPort
      io.bus.ready := true.B
      when(io.bus.enable) {
        when(io.bus.write) {
          busRwPort := io.bus.data_in
        }
      }
    } else {
      io.bus.data_out := DontCare
    }

    // Core has priority over bus
    val coreRwPort = ispm(io.core.rw.addr)
    if (conf.iMemCoreRW) {
      io.core.rw.data_out := coreRwPort
      when(io.core.rw.enable) {
        if(conf.iMemBusRW) io.bus.ready := false.B
        when(io.core.rw.write) {
          coreRwPort := io.core.rw.data_in
        }
      }
    }
  } else {
    io.bus.ready := false.B
  }
}
