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

  val cfg = FlexpretConfiguration(threads = 1, flex = false, clkFreqMHz=100,
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

      c.clock.step(1)

      // Check for errors
      wbExpectRead(c, Constants.CSR_ADDR, 0)
    }
  }

  it should "do a read" in {
    test(wb) { c =>
      // Read the magic register
      wbExpectRead(c, Constants.CONST_ADDR, Constants.CONST_VALUE)
      
      c.clock.step(1)
      
      // Check for errors in CSR
      wbExpectRead(c, Constants.CSR_ADDR, 0)
    }
  }

  it should "write a bad address, get an error and clear it" in {
    test(wb) { c => 
      // Should initially be zero
      wbExpectRead(c, Constants.CSR_ADDR, 0)
      c.clock.step(1)

      // Write to a bad address
      wbWrite(c, 2, 0)
      c.clock.step(1)

      // Expect bad addr bit set
      wbExpectRead(c, Constants.CSR_ADDR, (1 << Constants.FAULT_BAD_ADDR_BIT))
      c.clock.step(1)

      // Bad addr bit is automatically cleared on reading the CSR, which we just did
      wbExpectRead(c, Constants.CSR_ADDR, 0)
    }
  }
}
