/******************************************************************************
File: dspm.scala
Description: Data scratchpad memory
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._

class DataMemCoreIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  // read/write port
  val addr = UInt(INPUT, conf.dMemAddrBits-2) // assume word aligned
  val enable = Bool(INPUT)
  val data_out = Bits(OUTPUT, 32)
  val byte_write = Vec.fill(4) { Bool(INPUT) }
  val data_in = Bits(INPUT, 32)
}

class DSpm(implicit conf: FlexpretConfiguration) extends Module
// TODO: rename blackbox signals
//class DSRAM(conf: FlexpretConfiguration) extends BlackBox
{
  val io = new Bundle {
    val core = new DataMemCoreIO()
    val bus = new DataMemBusIO()
  }
  
  // memory for data SPM
  val dspm = Mem(Bits(width = 32), conf.dMemDepth, true)


  // read/write port for core
  val dout = Reg(Bits(width = 32)) // infer sequential read
  io.core.data_out := dout

  when(io.core.enable) {
    val current = dspm(io.core.addr)
    dout := current
    dspm(io.core.addr) := Cat(
      Mux(io.core.byte_write(3), io.core.data_in(31, 24), current(31, 24)),
      Mux(io.core.byte_write(2), io.core.data_in(23, 16), current(23, 16)),
      Mux(io.core.byte_write(1), io.core.data_in(15,  8), current(15,  8)),
      Mux(io.core.byte_write(0), io.core.data_in( 7,  0), current( 7,  0))
    )
  }

  // TODO: read/write port for bus
}
