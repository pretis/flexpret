package flexpret.Wishbone

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import wishbone._

object WishboneDeviceUtils {
  def wbWrite(c: WishboneDevice, addr: Int, data: Int) = {
    timescope {
      c.io.port.we.poke(true.B)
      c.io.port.addr.poke(addr.U)
      c.io.port.wrData.poke(data.U)
      c.io.port.cyc.poke(true.B)
      c.io.port.stb.poke(true.B)
      c.io.port.sel.poke(15.U)
      c.clock.step(1)
      c.io.port.ack.expect(true.B)
    }
  }

  def wbExpectRead(c: WishboneDevice, addr: Int, eData: Int) = {
    timescope {
      c.io.port.we.poke(false.B)
      c.io.port.addr.poke(addr.U)
      c.io.port.cyc.poke(true.B)
      c.io.port.stb.poke(true.B)
      c.io.port.sel.poke(15.U)
      c.clock.step(1)
      c.io.port.ack.expect(true.B)
      c.io.port.rdData.expect(eData.U)

    }
  }
}
