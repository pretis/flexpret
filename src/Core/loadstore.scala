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
    val thread = UInt(INPUT, conf.threadBits)
    val load = Bool(INPUT)
    val store = Bool(INPUT)
    val mem_type = UInt(INPUT, MEM_WI)
    val data_in = Bits(INPUT, 32)
    val data_out = Bits(OUTPUT, 32)
    // memory protection
    val imem_protection = Vec.fill(conf.memRegions) { UInt(INPUT, MEMP_WI) }
    val dmem_protection = Vec.fill(conf.memRegions) { UInt(INPUT, MEMP_WI) }
    // exceptions
    val kill = Bool(INPUT)
    val load_misaligned  = Bool(OUTPUT)
    val load_fault       = Bool(OUTPUT)
    val store_misaligned = Bool(OUTPUT)
    val store_fault      = Bool(OUTPUT)
  }

  // Preserve byte location and type of operation.
  val addr_byte_reg = Reg(next = io.addr(1, 0))
  val mem_type_reg = Reg(next = io.mem_type)
  
  // Determine source/destination by address range
  val dmem_op = io.addr(31, 32-ADDR_DSPM_BITS) === ADDR_DSPM_VAL
  val imem_op = io.addr(31, 32-ADDR_ISPM_BITS) === ADDR_ISPM_VAL
  val bus_op  = io.addr(31, 32-ADDR_BUS_BITS)  === ADDR_BUS_VAL
  // Check if address overflows size
  // spike val bad_address = Bool(false)
  val bad_address = (
    (dmem_op && io.addr(31-ADDR_DSPM_BITS, conf.dMemAddrBits) != Bits(0)) ||
    (imem_op && io.addr(31-ADDR_ISPM_BITS, conf.iMemAddrBits+2) != Bits(0)) ||
    (bus_op  && io.addr(31-ADDR_BUS_BITS,  conf.busAddrBits-conf.threadBits) != Bits(0)) )

  // Memory protection (for write)
  val permission = Bool()
  if(conf.memProtection) {
    // determine region mode using address to index
    val imem_region_mode = io.imem_protection(io.addr(conf.iMemHighIndex, conf.iMemLowIndex))
    val dmem_region_mode = io.dmem_protection(io.addr(conf.dMemHighIndex, conf.dMemLowIndex))
    // check for permission (shared or matching thread ID)
    val imem_permission = ((imem_region_mode === MEMP_SH) || (imem_region_mode(conf.threadBits-1,0) === io.thread)) && (imem_region_mode != MEMP_RO)
    val dmem_permission = ((dmem_region_mode === MEMP_SH) || (dmem_region_mode(conf.threadBits-1,0) === io.thread)) && (dmem_region_mode != MEMP_RO)
    // check for exception
    permission := (dmem_op && dmem_permission) || (imem_op && imem_permission) || bus_op
  } else {
    permission := Bool(true)
  }

  // Exception checks
  val load_misaligned = Bool()
  load_misaligned := Bool(false)
  if(conf.causes.contains(Causes.misaligned_load)) {
    load_misaligned := io.load && (
      (((io.mem_type === MEM_LH) || (io.mem_type === MEM_LHU)) && (io.addr(0) != Bits(0))) ||
      ((io.mem_type === MEM_LW) && (io.addr(1,0) != Bits(0))))
  }
  val load_fault = Bool()
  load_fault := Bool(false)
  if(conf.causes.contains(Causes.fault_load)) {
    load_fault := io.load && bad_address
  }
  val store_misaligned = Bool()
  store_misaligned := Bool(false)
  if(conf.causes.contains(Causes.misaligned_store)) {
    store_misaligned := io.store && (
      ((io.mem_type === MEM_SH) && (io.addr(0) != Bits(0))) ||
      ((io.mem_type === MEM_SW) && (io.addr(1,0) != Bits(0))))
  }
  val store_fault = Bool()
  store_fault := Bool(false)
  if(conf.causes.contains(Causes.fault_store)) {
    store_fault := io.store && (bad_address || !permission)
  }
 
  // remember last operation
  val dmem_op_reg = Reg(next = dmem_op)
  val imem_op_reg = Reg(next = imem_op)
 
  val write = io.store && permission && !store_misaligned && !store_fault && !io.kill
  // data memory input
  io.dmem.addr := io.addr(conf.dMemAddrBits-1, 2) // assumes aligned
  io.dmem.data_in := StoreFormat(io.data_in, io.mem_type)
  io.dmem.enable := (if(conf.dMemForceEn) Bool(true)
                    else dmem_op && (io.load || io.store))
  io.dmem.byte_write := StoreMask(io.addr(1, 0), io.mem_type) & 
                        Fill(write.toBits, 4)


  // instruction memory input
  // no subword
  if(conf.iMemCoreRW) {
    io.imem.rw.addr := io.addr(conf.iMemAddrBits-1, 2) // assumes word aligned
    io.imem.rw.data_in := io.data_in // TODO: currently only supports word write
    io.imem.rw.enable := (if(conf.iMemForceEn) Bool(true) 
                          else imem_op && (io.load || io.store))
    io.imem.rw.write := imem_op && write
  } else {
    io.imem.rw.enable := Bool(false)
    io.imem.rw.write := Bool(false)
  }

  // bus input
  // no subword
  // TODO: add thread ID
  io.bus.addr := Cat(io.thread, io.addr(conf.busAddrBits-conf.threadBits-1,0))
  io.bus.data_in := io.data_in
  io.bus.enable := bus_op && (io.load || io.store)
  io.bus.write := bus_op && write

  // Determine enable and write control signals based on address.
  io.data_out := Mux(dmem_op_reg, LoadFormat(io.dmem.data_out, addr_byte_reg, mem_type_reg),
                 Mux(imem_op_reg, io.imem.rw.data_out,
                     io.bus.data_out))
    
  io.load_misaligned  := load_misaligned
  io.load_fault       := load_fault
  io.store_misaligned := store_misaligned
  io.store_fault      := store_fault

}

