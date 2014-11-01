/******************************************************************************
File: ispm.scala
Description: Instruction scratchpad memory
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._

class InstMemCoreIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  val r = new Bundle {
    // read port
    val addr = UInt(INPUT, conf.iMemAddrBits)
    val enable = Bool(INPUT)
    val data_out = Bits(OUTPUT, 32)
  }
  val rw = new Bundle {
    // read/write port
    val addr = UInt(INPUT, conf.iMemAddrBits)
    val enable = Bool(INPUT)
    val data_out = Bits(OUTPUT, 32)
    val write = Bool(INPUT)
    val data_in = Bits(INPUT, 32)
  }
}

class ISpm(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new Bundle {
    val core = new InstMemCoreIO()
    val bus = new InstMemBusIO()
  }

  // memory for instruction SPM
  val ispm = Mem(Bits(width = 32), conf.iMemDepth, true)

  // read port
  // infer sequential read
  val dout_r = Reg(Bits(width = 32))
  io.core.r.data_out := dout_r

  // Read port connected to core for instruction fetch.
  when(io.core.r.enable) {
    dout_r := ispm(io.core.r.addr)
  }

  // read/write port
  // infer sequential read
  val dout_rw = Reg(Bits(width = 32))
  io.core.rw.data_out := dout_rw
  
  // Read/write port connected to datapath (has priority) and external bus.
  when(io.core.rw.enable) {
    io.bus.ready := Bool(false)
    dout_rw := ispm(io.core.rw.addr)
    when(io.core.rw.write) {
      ispm(io.core.rw.addr) := io.core.rw.data_in
    }
  } .otherwise {
    io.bus.ready := Bool(true)
    when(io.bus.write) {
      ispm(io.bus.addr) := io.bus.data_in
    }
  }
}
