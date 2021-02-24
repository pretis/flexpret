/******************************************************************************
Description: CSR tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import org.scalatest._

import chisel3._

import chiseltest._
import chiseltest.experimental.TestOptionBuilder._

import Core.FlexpretConstants._
import Core.CSRs

import flexpret.core.CSR
import flexpret.core.FlexpretConfiguration
import flexpret.core.InstMemConfiguration

class CSRTestHelper(val c: CSR) {
  /**
   * Write a CSR. Note that this does NOT step the clock.
   */
  def writeCSR(csr: Int, value: UInt): Unit = {
    c.io.rw.addr.poke(csr.U)
    c.io.rw.csr_type.poke(CSR_W)
    c.io.rw.data_in.poke(value)
    c.io.rw.write.poke(true.B)
  }

  /**
   * Read a CSR.
   */
  def readCSR(csr: Int): UInt = {
    var out: UInt = null // bad, but needed to pass things out from a timescope
    timescope {
      c.io.rw.addr.poke(csr.U)
      c.io.rw.write.poke(false.B)
      // Note: data_out is read combinationally!!!
      out = c.io.rw.data_out.peek()
    }
    out
  }
}

class CSRTest extends FlatSpec with ChiselScalatestTester {
  behavior of "CSR"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, features="all")
  def csr = new CSR()(conf=conf)

  implicit def csrToHelper(c: CSR) = new CSRTestHelper(c)

  it should "write a GPIO CSR" in {
    test(csr).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // This assumes the default hardcoded convention of 4 GPOs
        c.writeCSR(CSRs.gpoBase, 3.U)
        c.clock.step()
        c.writeCSR(CSRs.gpoBase + 1, 1.U)
        c.clock.step()
        c.writeCSR(CSRs.gpoBase + 2, 0.U)
        c.clock.step()
        c.writeCSR(CSRs.gpoBase + 3, 2.U)
        c.clock.step()
      }
      c.io.gpio.out(0).expect(3.U)
      c.io.gpio.out(1).expect(1.U)
      c.io.gpio.out(2).expect(0.U)
      c.io.gpio.out(3).expect(2.U)
    }
  }

  it should "read a GPIO CSR" in {
    test(csr).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // Set the inputs
        c.io.gpio.in(0).poke(1.U)
        c.io.gpio.in(1).poke(1.U)
        c.io.gpio.in(2).poke(0.U)
        c.io.gpio.in(3).poke(1.U)
        c.clock.step()
        // Read them.
        assert(c.readCSR(CSRs.gpiBase).litValue() == 1)
        assert(c.readCSR(CSRs.gpiBase + 1).litValue() == 1)
        assert(c.readCSR(CSRs.gpiBase + 2).litValue() == 0)
        assert(c.readCSR(CSRs.gpiBase + 3).litValue() == 1)
      }
    }
  }

  it should "write tohost" in {
    test(csr).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        val csrVal = "habcd_ef88".U
        c.writeCSR(CSRs.tohost, csrVal)
        c.clock.step()
        c.io.host.to_host.expect(csrVal)
      }
      timescope {
        val csrVal = "h1234_5678".U
        c.writeCSR(CSRs.tohost, csrVal)
        c.clock.step()
        c.io.host.to_host.expect(csrVal)
      }
    }
  }
}
