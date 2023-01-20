/******************************************************************************
File: ispm.scala
Description: Instruction scratchpad memory
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util._
import _root_.dataclass.data

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

class TrueDualPortBram(addrBits: Int, dataBits: Int) 
extends BlackBox(Map("DATA" -> dataBits, "ADDR" -> addrBits)) {
  val io = IO(new Bundle {
    val clk = Input(Clock())
    val a_wr = Input(Bool())
    val a_addr = Input(UInt(addrBits.W))
    val a_din = Input(UInt(dataBits.W))
    val a_dout = Output(UInt(dataBits.W))
    
    val b_wr = Input(Bool())
    val b_addr = Input(UInt(addrBits.W))
    val b_din = Input(UInt(dataBits.W))
    val b_dout = Output(UInt(dataBits.W))
  })
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
  val ispm = Module(new TrueDualPortBram(conf.iMemDepth, 32))




  // read port
  ispm.io.a_addr := io.core.r.addr
  ispm.io.a_wr := false.B
  ispm.io.a_din := 0.U
  io.core.r.data_out := ispm.io.a_dout

  // Second read/write port
  if (conf.iMemCoreRW || conf.iMemBusRW) {
    // Drive default
    ispm.io.b_wr := false.B
    ispm.io.b_addr := 0.U
    ispm.io.b_din := 0.U

    if (conf.iMemBusRW) {
      ispm.io.b_addr := io.bus.addr
      io.bus.data_out := ispm.io.b_dout
      io.bus.ready := true.B
      when(io.bus.enable) {
        when(io.bus.write) {
          ispm.io.b_din := io.bus.data_in
        }
      }
    } else {
      io.bus.data_out := DontCare
    }

    // Core has priority over bus
    if (conf.iMemCoreRW) {
      ispm.io.b_addr := io.core.rw.addr
      io.core.rw.data_out := ispm.io.b_dout
      when(io.core.rw.enable) {
        if(conf.iMemBusRW) io.bus.ready := false.B
        when(io.core.rw.write) {
          ispm.io.b_wr := true.B
          ispm.io.b_din := io.core.rw.data_in
        }
      }
    }
  } else {
    io.bus.ready := false.B
  }
}
