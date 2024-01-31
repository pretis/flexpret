package interpret

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

import flexpret.core.{FlexpretConfiguration, InstMemConfiguration}
import flexpret.Wishbone.WishboneDeviceUtils._
import flexpret.{WishboneUart, Constants}

class WishboneUartTest extends AnyFlatSpec with ChiselScalatestTester {

  behavior of "WishboneUart"

  val READ_ADDR = 0
  val WRITE_ADDR = 4
  val WRITE_DATA = 8
  val READ_DATA = 12
  val STATUS = 16

  val cfg = FlexpretConfiguration(threads = 1, flex = false,
    InstMemConfiguration(bypass = true, sizeKB = 4),
    dMemKB = 256, mul = false, priv = false, features = "all"
  )

  def wb = new WishboneUart()(cfg)

  it should "initialize" in {
    test(wb) { c =>
      c.io.port.rdData.expect(false.B)
      c.ioUart.tx.expect(true.B)
    }
  }

  it should "receive write" in {
    test(wb) { c =>
      wbWrite(c, Constants.TX_ADDR, 8)
    }
  }

  it should "do a read" in {
    test(wb) { c =>
      wbExpectRead(c, Constants.CSR_ADDR, 0)
    }
  }
}
