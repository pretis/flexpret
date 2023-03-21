/******************************************************************************
File: dspm.scala
Description: Data scratchpad memory
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._

class DataMemCoreIO(implicit conf: FlexpretConfiguration) extends Bundle {
  // read/write port
  val addr = Input(UInt((conf.dMemAddrBits-2).W)) // assume word aligned
  val enable = Input(Bool())
  val data_out = Output(UInt(32.W))
  val byte_write = Input(Vec(4, Bool()))
  val data_in = Input(UInt(32.W))
}

class DSpm(implicit conf: FlexpretConfiguration) extends Module {
  val io = IO(new Bundle {
    val core = new DataMemCoreIO()
    val bus = new DataMemBusIO()
  })

  def split(in: UInt): Vec[UInt] = {
    VecInit(
      in(7, 0),
      in(15, 8),
      in(23, 16),
      in(31, 24)
    )
  }

  // memory for data SPM
  // Sequential-read, sequential-write
  val dspm = SyncReadMem(conf.dMemDepth, Vec(4, UInt(8.W)))

  // read/write port for core
  val corePort = dspm.read(io.core.addr, io.core.enable)
  io.core.data_out := corePort.asUInt
  when (io.core.enable) {
    dspm.write(io.core.addr, split(io.core.data_in), io.core.byte_write)
  }

  if(conf.dMemBusRW) { 
    // read/write port for bus
    val busPort = dspm.read(io.bus.addr, io.bus.enable)
    io.bus.data_out := busPort.asUInt
    when (io.bus.enable) {
      dspm.write(io.bus.addr, split(io.bus.data_in), io.bus.byte_write)
    }
  } else {
    io.bus.data_out := 0.U
  }
}
