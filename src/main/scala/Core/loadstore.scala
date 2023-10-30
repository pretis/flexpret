/******************************************************************************
File: loadstore.scala
Description: Handle load/store operations to D-SPM, I-SPM, or bus
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package Core

import chisel3._
import chisel3.util._
import FlexpretConstants._

// Remove this eventually
import flexpret.core.BusIO
import flexpret.core.DataMemCoreIO
import flexpret.core.InstMemCoreIO
import flexpret.core.FlexpretConfiguration

// Use byte address within word (lowest 2 bits) and type of load to correctly
// format loaded data.
object LoadFormat {
  def apply(data: Bits, address: UInt, memType: UInt) = {
    // Shift data to move subword loads to lowest bytes.
    // Address -> Shift Amount: 00->0, 01->8, 10->16, 11->24
    val shifted = data >> (Cat(address, 0.U(3.W)))

    // Zero or sign extend.
    Mux(memType === MEM_LB,  Cat(Fill(24, shifted( 7)), shifted(7,  0)),
    Mux(memType === MEM_LBU, Cat(0.U(24.W),             shifted(7,  0)),
    Mux(memType === MEM_LH,  Cat(Fill(16, shifted(15)), shifted(15, 0)),
    Mux(memType === MEM_LHU, Cat(0.U(16.W),             shifted(15, 0)),
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

/**
 * Use byte address within word (lowest 2 bits) and type of store to
 * correctly format the byte store mask (4 bits).
 * e.g. 1111 means write all 4 bytes (32 bits).
 * e.g. 0001 means only write lower byte.
 */
object StoreMask {
  def apply(address: UInt, memType: UInt, enable: Bool): UInt = {
    val result = Wire(UInt(4.W))
    result := chisel3.DontCare

    // Use a when structure to only enable the assert if enabled.
    // Otherwise return a DontCare.
    when (enable) {
      require(address.widthOption.get >= 2, "Byte address must be 2+ bits")
      val addressLastTwo = address(1, 0)

      // Store mask for subword stores depends on address.
      // Byte store: 00->0001, 01->0010, 10->0100, 11->1000
      // Half-word store: 00->0011, 10->1100
      // Word store: 00->1111
      when (memType === MEM_SH) {
        // Half-word stores must have an LSB of 0
        assert(addressLastTwo(0) === 0.U)
      }
      result := Mux(memType === MEM_SB, (1.U(1.W) << addressLastTwo)(3, 0),
      Mux(memType === MEM_SH, ("b11".U(2.W) << addressLastTwo)(3, 0),
      Mux(memType === MEM_SW, 15.U(4.W),
                              0.U(4.W))))
    }
    result
  }
}

class LoadStore(implicit val conf: FlexpretConfiguration) extends Module
{
  val io = IO(new Bundle {
    // connections to memories and bus
    val dmem = Flipped(new DataMemCoreIO())
    val imem = Flipped(new InstMemCoreIO()) // only use write port
    val bus = Flipped(new BusIO())
    // connection to datapath
    val addr = Input(UInt(32.W))
    val thread = Input(UInt(conf.threadBits.W))
    val load = Input(Bool())
    val store = Input(Bool())
    val mem_type = Input(UInt(MEM_WI.W))
    val data_in = Input(Bits(32.W))
    val data_out = Output(Bits(32.W))
    // memory protection
    val imem_protection = Vec(conf.memRegions, Input(UInt(MEMP_WI.W)))
    val dmem_protection = Vec(conf.memRegions, Input(UInt(MEMP_WI.W)))
    // exceptions
    val kill = Input(Bool())
    val load_misaligned  = Output(Bool())
    val load_fault       = Output(Bool())
    val store_misaligned = Output(Bool())
    val store_fault      = Output(Bool())

    val imem_store = Output(Bool())
  })

  // Preserve byte location and type of operation.
  val addr_byte_reg = RegNext(io.addr(1, 0))
  val mem_type_reg = RegNext(io.mem_type)

  // Determine source/destination by address range
  val dmem_op = io.addr(31, 32-ADDR_DSPM_BITS) === ADDR_DSPM_VAL
  val imem_op = io.addr(31, 32-ADDR_ISPM_BITS) === ADDR_ISPM_VAL
  val bus_op  = io.addr(31, 32-ADDR_BUS_BITS)  === ADDR_BUS_VAL
  // Check if address overflows size
  // spike val bad_address = false.B
  val bad_address = (
    (dmem_op && io.addr(31-ADDR_DSPM_BITS, conf.dMemAddrBits) =/= 0.U) ||
    (imem_op && io.addr(31-ADDR_ISPM_BITS, conf.iMemAddrBits+2) =/= 0.U) ||
    (bus_op  && io.addr(31-ADDR_BUS_BITS,  conf.busAddrBits-conf.threadBits) =/= 0.U) )

  io.imem_store := imem_op && io.store

  // Memory protection (for write)
  val permission = Wire(Bool())
  if(conf.memProtection) {
    // determine region mode using address to index
    val imem_region_mode = io.imem_protection(io.addr(conf.iMemHighIndex, conf.iMemLowIndex))
    val dmem_region_mode = io.dmem_protection(io.addr(conf.dMemHighIndex, conf.dMemLowIndex))
    // check for permission (shared or matching thread ID)
    val imem_permission = ((imem_region_mode === MEMP_SH) || (imem_region_mode(conf.threadBits-1,0) === io.thread)) && (imem_region_mode =/= MEMP_RO)
    val dmem_permission = ((dmem_region_mode === MEMP_SH) || (dmem_region_mode(conf.threadBits-1,0) === io.thread)) && (dmem_region_mode =/= MEMP_RO)
    // check for exception
    permission := (dmem_op && dmem_permission) || (imem_op && imem_permission) || bus_op
  } else {
    permission := true.B
  }

  // Exception checks
  val load_misaligned = Wire(Bool())
  load_misaligned := false.B
  if(conf.causes.contains(Causes.misaligned_load)) {
    load_misaligned := io.load && (
      (((io.mem_type === MEM_LH) || (io.mem_type === MEM_LHU)) && (io.addr(0) =/= 0.U)) ||
      ((io.mem_type === MEM_LW) && (io.addr(1,0) =/= 0.U)))
  }
  val load_fault = Wire(Bool())
  load_fault := false.B
  if(conf.causes.contains(Causes.fault_load)) {
    load_fault := io.load && bad_address
  }
  val store_misaligned = Wire(Bool())
  store_misaligned := false.B
  if(conf.causes.contains(Causes.misaligned_store)) {
    store_misaligned := io.store && (
      ((io.mem_type === MEM_SH) && (io.addr(0) =/= 0.U)) ||
      ((io.mem_type === MEM_SW) && (io.addr(1,0) =/= 0.U)))
  }
  val store_fault = Wire(Bool())
  store_fault := false.B
  if(conf.causes.contains(Causes.fault_store)) {
    store_fault := io.store && (bad_address || !permission)
  }

  // remember last operation
  val dmem_op_reg = RegNext(dmem_op)
  val imem_op_reg = RegNext(imem_op)

  val write: Bool = io.store && permission && !store_misaligned && !store_fault && !io.kill
  // data memory input
  io.dmem.addr := io.addr(conf.dMemAddrBits-1, 2) // assumes aligned
  io.dmem.data_in := StoreFormat(io.data_in, io.mem_type)
  val dmem_enable: Bool = if(conf.dMemForceEn) true.B else (dmem_op && (io.load || io.store))
  io.dmem.enable := dmem_enable
  io.dmem.byte_write := (StoreMask(io.addr(1, 0), io.mem_type, enable=dmem_enable) & Fill(4, write.asUInt)).asBools


  // instruction memory input
  // no subword
  io.imem.r := DontCare
  if(conf.iMemCoreRW) {
    io.imem.rw.addr := io.addr(conf.iMemAddrBits-1, 2) // assumes word aligned
    io.imem.rw.data_in := io.data_in // TODO: currently only supports word write
    io.imem.rw.enable := (if(conf.iMemForceEn) true.B
                          else imem_op && (io.load || io.store))
    io.imem.rw.write := imem_op && write
  } else {
    io.imem.rw.enable := false.B
    io.imem.rw.write := false.B
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

  // Assertions
  assert(!load_misaligned, "Load misaligned")
  assert(!load_fault, "Load fault")
  assert(!store_misaligned, "Store misaligned")
  assert(!store_fault, "Store fault")
}

