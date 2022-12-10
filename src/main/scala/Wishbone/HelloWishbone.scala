package flexpret.Wishbone

import chisel3._
import chisel3.util._

/**
 * Just a Wishbone interface, without any additional connection.
 *
 */
abstract class WishboneDevice(addrWidth: Int) extends Module {
  val io = IO(Flipped(new WishboneIO(addrWidth)))
}

/**
 * An minimal Wishbone IO device in pipelined mode.
 * It contains a single register to write and read.
 *
 * To stress the master a bit, it varies the ack timing.
 */
class HelloWishbone() extends WishboneDevice(2) {

  val port = io
  port.rdData := 0.U
  port.ack := false.B

  val longAckReg = RegInit(false.B)
  val dataReg = RegInit(0.U(32.W))
  val cntReg = RegInit(0.U)

  val idle :: read :: write :: Nil = Enum(3)
  val stateReg = RegInit(idle)

  val start = port.cyc & port.stb

  switch (stateReg) {
    is (idle) {
      when(start) {
        when(port.we) {
          dataReg := port.wrData
          stateReg := write
        }.otherwise {
          stateReg := read
        }
        when (longAckReg) {
          cntReg := 3.U
        } .otherwise {
          cntReg := 0.U
        }
        longAckReg != longAckReg
      }
    }
    is(write) {
      when (cntReg === 0.U) {
        port.ack := true.B
        stateReg := idle
      } .otherwise {
        cntReg := cntReg - 1.U
      }
    }
    is(read) {
      when(cntReg === 0.U) {
        port.ack := true.B
        stateReg := idle
      }.otherwise {
        cntReg := cntReg - 1.U
      }
      when(port.ack) {
        port.rdData := dataReg
      }
    }
  }
}