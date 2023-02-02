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

class DualPortBram(addrBits: Int, dataBits: Int) 
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
  val ispm = Module(new DualPortBram(conf.iMemAddrBits, 32))
  ispm.io.clk := clock

  // read port
  ispm.io.a_addr := io.core.r.addr
  ispm.io.a_wr := false.B
  ispm.io.a_din := 0.U
  io.core.r.data_out := ispm.io.a_dout

  // Second read/write port
  if (conf.iMemCoreRW || conf.iMemBusRW) {
    // read/write port
    val addr = WireDefault(0.U(32.W))
    val writeData = WireDefault(0.U(32.W))
    val write = WireDefault(false.B)
    ispm.io.b_addr := addr
    ispm.io.b_wr := write
    ispm.io.b_din := writeData
    val readData = ispm.io.b_dout

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
