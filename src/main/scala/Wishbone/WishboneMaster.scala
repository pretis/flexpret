package flexpret.Wishbone
import chisel3._
import chisel3.util._
import Core.FlexpretConstants._
import flexpret.core.{BusIO, FlexpretConfiguration}

import wishbone.{WishboneIO}

// class WishboneIO(addrBits: Int) extends Bundle {
//   val addr = Output(UInt(addrBits.W))
//   val wrData = Output(UInt(32.W))
//   val rdData = Input(UInt(32.W))
//   val we = Output(Bool())
//   val sel = Output(UInt(4.W))
//   val stb = Output(Bool())
//   val ack = Input(Bool())
//   val cyc = Output(Bool())

//   def driveReadReq(_addr: UInt): Unit = {
//     addr := _addr
//     wrData := 0.U
//     we := false.B
//     cyc := true.B
//     sel := 15.U// Assume we always want 4 bytes for now
//     stb := true.B
//   }

//   def driveWriteReq(_addr: UInt, data: UInt) = {
//     addr := _addr
//     wrData := data
//     we := true.B
//     cyc := true.B
//     sel := 15.U // Assume we always want 4 bytes for now
//     stb := true.B
//   }

//   def driveDefaults(): Unit = {
//     addr := 0.U
//     wrData := 0.U
//     we := false.B
//     cyc := false.B
//     sel := 0.U
//     stb := 0.U
//   }
//   def driveDefaultsFlipped(): Unit = {
//     rdData := 0.U
//     ack := false.B
//   }
// }

class WishboneMaster(addrBits: Int)(implicit conf: FlexpretConfiguration) extends Module {
  val wbIO = IO(new WishboneIO(addrBits))
  val busIO = IO(new BusIO())

  wbIO.setDefaults()
  busIO.driveDefaults() // FIXME: Change to setDefaults

  // Registers with 1CC access latency from FlexPret core
  val regAddr = RegInit(0.U(conf.busAddrBits.W))
  val regWriteData = RegInit(0.U(32.W))
  val regReadData = RegInit(0.U(32.W))
  val regStatus = RegInit(false.B)

  // Use a single register to delay read-out for a single cycle
  val regBusRead = RegInit(0.U(32.W))
  busIO.data_out := regBusRead


  // Simple, un-optimized implementation of the wishbone protocol
  val sIdle :: sDoWrite :: sDoRead :: Nil = Enum(3)
  val regState = RegInit(sIdle)

  val wDoRead = WireDefault(false.B)
  val wDoWrite = WireDefault(false.B)
  assert(!(wDoRead && wDoWrite), "Both read and write at the same time")
  assert(!(busIO.enable && regState =/= sIdle), "Recevied bus request while busy")

  switch(regState) {
    // Idle state. Waiting for request from FlexPret Core
    //  Decouples the FlexPret load/store instructions from
    //  accessing the WB bus
    is (sIdle) {
      // Handle read/write transactions from core
      when(busIO.enable) {
        val addr = busIO.addr
        when(busIO.write) {
          // Handle writes
          when(addr === MMIO_READ_ADDR) {
            regAddr := busIO.data_in
            // Writing to the READ_ADDR will trigger a read on the WB bus
            wDoRead := true.B
          }.elsewhen(addr === MMIO_WRITE_ADDR) {
            regAddr := busIO.data_in
            // Writing to the WRITE_ADDR will trigger a write on the WB bus
            //  the WRITE_DATA register must be written before the write to the addr
            wDoWrite := true.B
          }.elsewhen(addr === MMIO_WRITE_DATA) {
            regWriteData := busIO.data_in
          }.otherwise {
            assert(false.B, "Tried to write to invalid address %d on wishbone bus master",addr)
          }
        }.otherwise {
          // Handle reads
          when(addr === MMIO_READ_DATA) {
            regBusRead := regReadData
          }.elsewhen(addr === MMIO_STATUS) {
            regBusRead := regStatus
            regStatus := false.B
          }.otherwise {
            assert(false.B, "Tried to read from invalid address %d on wishbone bus master", addr)
          }
        }
      }
      when (wDoRead) {
        regState := sDoRead
      }.elsewhen(wDoWrite) {
        regState := sDoWrite
      }
//      assert(!wbIO.ack, "WBm in idle mode and recived ACK")
    }

    // Perform read operation. Drive read signals until we get an ack
    is (sDoRead) {
      wbIO.driveReadReq(regAddr)
      regStatus := false.B
      when(wbIO.ack) {
        regReadData := wbIO.rdData
        regStatus := true.B
        regState := sIdle
      }
    }

    // Perform write operation. Drive write signals until we get an ack
    is (sDoWrite) {
      wbIO.driveWriteReq(regAddr, regWriteData)
      regStatus := false.B
      when(wbIO.ack) {
        regStatus := true.B
        regState := sIdle
      }
    }
  }
}
