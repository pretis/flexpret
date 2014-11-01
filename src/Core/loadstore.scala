/******************************************************************************
File: loadstore.scala
Description: Handle load/store operations to D-SPM, I-SPM, or bus
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

// Use byte address within word (lowest 2 bits) and type of load to correctly
// format loaded data.
object LoadFormat {
  def apply(data: Bits, address: UInt, memType: UInt) = {
    // Shift data to move subword loads to lowest bytes.
    // Address -> Shift Amount: 00->0, 01->8, 10->16, 11->24
    // TODO: wait until chisel bug is fixed
    //val shifted = data >> (Cat(address, UInt(0,3)))
    val shifted = UInt(data) >> (Cat(address, UInt(0,3)))

    // Zero or sign extend.
    Mux(memType === MEM_LB,  Cat(Fill(24, shifted( 7)), shifted(7,  0)),
    Mux(memType === MEM_LBU, Cat(Bits(0, 24),           shifted(7,  0)),
    Mux(memType === MEM_LH,  Cat(Fill(16, shifted(15)), shifted(15, 0)),
    Mux(memType === MEM_LHU, Cat(Bits(0, 16),           shifted(15, 0)),
                         shifted))))
  }
}

// Use type of store to correctly format data to store.
object StoreFormat {
  def apply(data: Bits, memType: UInt) = {
    // Align data for subword stores.
    // If data = ABCD
    // Byte store: DDDD
    // Half-word store: CDCD
    // Word store: ABCD
    Mux(memType === MEM_SB, Fill(4, data( 7, 0)),
    Mux(memType === MEM_SH, Fill(2, data(15, 0)),
                       data))
  }
}

// Use byte address within word (lowest 2 bits) and type of store to correctly
// format store mask.
object StoreMask {
  def apply(address: UInt, memType: UInt) = {
    // Store mask for subword stores depends on address.
    // Byte store: 00->0001, 01->0010, 10->0100, 11->1000
    // Half-word store: 00->0011, 10->1100
    // Word store: 00->1111
    Mux(memType === MEM_SB, Bits(1, 1) << address,
    Mux(memType === MEM_SH, Bits(3, 2) << address,
    Mux(memType === MEM_SW, Bits(15, 4),
                        Bits(0, 4))))
  }
}

class LoadStore(implicit conf: FlexpretConfiguration) extends Module
{
  val io = new Bundle {
    // connections to memories and bus
    val dmem = new DataMemCoreIO().flip
    val imem = new InstMemCoreIO().flip // only use write port
    val bus = new BusIO().flip
    // connection to datapath
    val addr = UInt(INPUT, 32)
    val load = Bool(INPUT)
    val store = Bool(INPUT)
    val mem_type = UInt(INPUT, MEM_WI)
    val data_in = Bits(INPUT, 32)
    val data_out = Bits(OUTPUT, 32)
  }

  // Preserve byte location and type of operation.
  val addr_byte_reg = Reg(next = io.addr(1, 0))
  val mem_type_reg = Reg(next = io.mem_type)

  // Determine source/destination by address range
  // TODO best way to handle?
  val dmem_op = io.addr(31, 32-ADDR_DSPM_BITS) === ADDR_DSPM_VAL
  val imem_op = io.addr(31, 32-ADDR_ISPM_BITS) === ADDR_ISPM_VAL
  val bus_op = Mux(dmem_op || imem_op, Bool(false), Bool(true))
  
  val dmem_op_reg = Reg(next = dmem_op)
  val imem_op_reg = Reg(next = imem_op)
 
  // data memory input
  io.dmem.addr := io.addr(conf.dMemAddrBits-1, 2) // assumes aligned
  io.dmem.data_in := StoreFormat(io.data_in, io.mem_type)
  io.dmem.enable := Mux(dmem_op, io.load || io.store, Bool(false))
  io.dmem.byte_write := StoreMask(io.addr(1, 0), io.mem_type) // assumes enable needed to write TODO: remove assumption?

  // instruction memory input
  io.imem.rw.addr := io.addr(conf.iMemAddrBits-1, 2) // assumes word aligned
  io.imem.rw.data_in := io.data_in // TODO: currently only supports word write
  io.imem.rw.enable := Mux(imem_op, io.load || io.store, Bool(false))
  io.imem.rw.write := Mux(imem_op, io.store, Bool(false))

  // bus input
  // TODO: support all load/store types, what is desired behavior?
  io.bus.addr := io.addr(conf.busAddrBits-1,0)
  io.bus.data_in := io.data_in
  io.bus.enable := Mux(bus_op, io.load || io.store, Bool(false))
  io.bus.write := Mux(bus_op, io.store, Bool(false))

  // Determine enable and write control signals based on address.
  io.data_out := Mux(dmem_op_reg, LoadFormat(io.dmem.data_out, addr_byte_reg, mem_type_reg),
                 Mux(imem_op_reg, io.imem.rw.data_out,
                     io.bus.data_out))

}

