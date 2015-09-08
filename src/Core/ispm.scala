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

// TODO: interal module for Blackbox
class ISpm(implicit conf: FlexpretConfiguration) extends BlackBox
//class ISpm(implicit conf: FlexpretConfiguration) extends Module
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

  if(conf.iMemCoreRW || conf.iMemBusRW) {
    // read/write port
    // infer sequential read
    val dout_rw = Reg(Bits(width = 32))

    if(conf.iMemBusRW) {
      io.bus.data_out := dout_rw
      io.bus.ready := Bool(true)
      when(io.bus.enable) {
        when(io.bus.write) {
          ispm(io.bus.addr) := io.bus.data_in
        }
        dout_rw := ispm(io.bus.addr)
      }
    }

    // Core has priority over bus
    if(conf.iMemCoreRW) {
      io.core.rw.data_out := dout_rw
      when(io.core.rw.enable) {
        if(conf.iMemBusRW) io.bus.ready := Bool(false)
        when(io.core.rw.write) {
          ispm(io.core.rw.addr) := io.core.rw.data_in
        }
        dout_rw := ispm(io.core.rw.addr)
      }
    }

  }
}
