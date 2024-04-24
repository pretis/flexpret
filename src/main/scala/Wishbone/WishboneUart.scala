package flexpret

import chisel3._
import chisel3.util._

import chisel.lib.uart.{Rx, Tx}
import chisel.lib.fifo
import wishbone.WishboneDevice
import flexpret.core.FlexpretConfiguration

object Constants {
  val TX_ADDR=0
  val RX_ADDR=4
  val CSR_ADDR=8
  val CONST_ADDR=12

  val DATA_RDY_BIT=0
  val TX_FIFO_FULL_BIT=1
  val FAULT_BAD_ADDR_BIT=2

  val CONST_VALUE=0x55
}
import Constants._

class WishboneUartIO extends Bundle {
  val rx = Input(Bool())
  val tx = Output(Bool())
}

class WishboneUart(implicit cfg: FlexpretConfiguration) extends WishboneDevice(4) {
  val ioUart = IO(new WishboneUartIO())

  val rx = Module(new Rx(cfg.clkFreqHz, cfg.uartBaudrate)).io
  val tx = Module(new Tx(cfg.clkFreqHz, cfg.uartBaudrate)).io

  ioUart.tx := tx.txd
  rx.rxd := ioUart.rx


  // FIXME: Use Martins FIFO
  // MS: Queue is fine as well
  val rxFifo = Module(new Queue(UInt(8.W), 8)).io
  val txFifo = Module(new Queue(UInt(8.W), 8)).io
  rx.channel <> rxFifo.enq
  tx.channel <> txFifo.deq
  txFifo.enq.valid :=false.B
  txFifo.enq.bits := 0.U
  rxFifo.deq.ready := false.B

  val fault_bad_addr = RegInit(false.B)

  // Status register 1. DataRdy, 2. TxFifoFull 3. Bad address
  val regCSR = RegInit(0.U(3.W))
  val wCSR = WireInit(VecInit(Seq.fill(3)(false.B)))
  wCSR(DATA_RDY_BIT) := rxFifo.deq.valid
  wCSR(TX_FIFO_FULL_BIT) := !txFifo.enq.ready
  wCSR(FAULT_BAD_ADDR_BIT) := fault_bad_addr
  regCSR := wCSR.asUInt

  // Read register
  val regReadData = RegInit(0.U(8.W))

  // Wire it up
  val port = io.port
  port.setDefaultsFlipped()
  port.rdData := regReadData

  val sIdle :: sRead :: sWrite :: Nil = Enum(3)
  val regState = RegInit(sIdle)
  val start = port.cyc & port.stb

  switch (regState) {
    is(sIdle) {
      when(start) {
        when(port.we) {
          when(port.addr === TX_ADDR.U) {
            txFifo.enq.valid := true.B
            txFifo.enq.bits := port.wrData
            assert(txFifo.enq.fire)
          }.otherwise {
            fault_bad_addr := true.B
          }
          regState := sWrite
        }.otherwise {
          when(port.addr === RX_ADDR.U) {
            regReadData := rxFifo.deq.bits
            rxFifo.deq.ready := true.B
            assert(rxFifo.deq.fire)
          }.elsewhen(port.addr === CSR_ADDR.U) {
            regReadData := regCSR
            fault_bad_addr := false.B
          }.elsewhen(port.addr === CONST_ADDR.U) {
            regReadData := CONST_VALUE.U
          }.otherwise {
            fault_bad_addr := true.B
          }
          regState := sRead
        }
      }
    }

    is(sWrite) {
      port.ack := true.B
      regState := sIdle
    }

    is(sRead) {
      port.ack := true.B
      regState := sIdle
      regReadData := 0.U
    }
  }
}
