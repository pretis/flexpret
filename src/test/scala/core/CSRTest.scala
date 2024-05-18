/******************************************************************************
Description: CSR tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import scala.language.implicitConversions

import chisel3._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import chiseltest._

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
    writeCSRtype(csr, value, CSR_W)
  }

  def writeCSRtype(csr: Int, value: UInt, typ: UInt): Unit = {
    c.io.rw.addr.poke(csr.U)
    c.io.rw.csr_type.poke(typ)
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

class CSRTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "CSR"

  val threads = 4
  val confNoPriv = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, priv=false, features="all")
  
  val confPriv = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, priv=true, features="all")

  val confDebug = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, priv=true, features="all")

  def csrNoPriv = new CSR("h00000000".asUInt(32.W), confNoPriv)
  def csrPriv   = new CSR("h00000000".asUInt(32.W), confPriv)
  def csrDebug  = new CSR("h00000000".asUInt(32.W), confDebug)

  implicit def csrToHelper(c: CSR) = new CSRTestHelper(c)

  it should "write a GPIO CSR" in {
    test(csrNoPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        /**
         * FIXME: 
         * Writes to GPIO CSR are not allowed without priviledge, and currently
         * there is no way to set the priviledge mode high.
         * 
         * So run this test without priviledge configuration.
        */

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
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // Set the inputs
        c.io.gpio.in(0).poke(1.U)
        c.io.gpio.in(1).poke(1.U)
        c.io.gpio.in(2).poke(0.U)
        c.io.gpio.in(3).poke(1.U)
        c.clock.step()
        // Read them.
        assert(c.readCSR(CSRs.gpiBase).litValue == 1)
        assert(c.readCSR(CSRs.gpiBase + 1).litValue == 1)
        assert(c.readCSR(CSRs.gpiBase + 2).litValue == 0)
        assert(c.readCSR(CSRs.gpiBase + 3).litValue == 1)
      }
    }
  }

  it should "write tohost" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        val csrVal = "habcd_ef88".U
        c.writeCSR(CSRs.tohost0, csrVal)
        c.clock.step()
        c.io.host.to_host(0).expect(csrVal)
      }
      timescope {
        val csrVal = "h1234_5678".U
        c.writeCSR(CSRs.tohost0, csrVal)
        c.clock.step()
        c.io.host.to_host(0).expect(csrVal)
      }
    }
  }

  it should "check that tohost registers do not intervene with each other" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        val csrVals = Vector("h12345678".U, "hdeaddead".U, "hbeefbeef".U, "hdeadbeef".U)
        
        c.writeCSR(CSRs.tohost0, csrVals(0))
        c.clock.step()
        c.writeCSR(CSRs.tohost1, csrVals(1))
        c.clock.step()
        c.writeCSR(CSRs.tohost2, csrVals(2))
        c.clock.step()
        c.writeCSR(CSRs.tohost3, csrVals(3))
        c.clock.step()

        c.io.host.to_host(0).expect(csrVals(0))
        c.io.host.to_host(1).expect(csrVals(1))
        c.io.host.to_host(2).expect(csrVals(2))
        c.io.host.to_host(3).expect(csrVals(3))
      }
    }
  }

  it should "check that fake writes to read-only CSRs are okay" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // Set bits with mask = 0 should be okay
        c.writeCSRtype(CSRs.time, "h0000_0000".U, CSR_S)
        c.clock.step()
        c.io.priv_fault.expect(0.U)

        // Set bits with mask != 0 should not be okay
        c.writeCSRtype(CSRs.time, "haab7_7781".U, CSR_S)
        c.clock.step()
        c.io.priv_fault.expect(1.U)

        // Clear bits with mask = 0 should be okay
        c.writeCSRtype(CSRs.time, "h0000_0000".U, CSR_C) 
        c.clock.step()
        c.io.priv_fault.expect(0.U)

        // Clear bits with mask != 0 should not be okay
        c.writeCSRtype(CSRs.time, "haab7_7781".U, CSR_S)
        c.clock.step()
        c.io.priv_fault.expect(1.U)

        // Writes should never be okay
        c.writeCSRtype(CSRs.time, "h0000_0000".U, CSR_W)
        c.clock.step()
        c.io.priv_fault.expect(1.U)

        c.writeCSRtype(CSRs.time, "haab7_7781".U, CSR_W)
        c.clock.step()
        c.io.priv_fault.expect(1.U)

        // Writes to RW CSRs should be fine
        c.writeCSRtype(CSRs.evec, "h0000_0000".U, CSR_W)
        c.clock.step()
        c.io.priv_fault.expect(0.U)

        c.writeCSRtype(CSRs.evec, "haab7_7781".U, CSR_W)
        c.clock.step()
        c.io.priv_fault.expect(0.U)
      }
    }
  }

  it should "check that a short delay until works as expected" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // Should trigger in two clock cycles, since each clock cycle increments
        // timer by 10 ns
        c.writeCSR(CSRs.compare_du_wu, "h00000014".U)
        c.clock.step()

        // Should now be false for tid = 0
        c.io.timer_expire_du_wu(0).expect(false.B)
        for (tid <- 1 until threads) {
          // Default value is triggered; i.e. not in use
          c.io.timer_expire_du_wu(tid).expect(true.B)
        }

        c.clock.step()
        // Should now be true
        c.io.timer_expire_du_wu(0).expect(true.B)
        for (tid <- 1 until threads) {
          // Default value is triggered; i.e. not in use
          c.io.timer_expire_du_wu(tid).expect(true.B)
        }
      }
    }
  }

  it should "check that multiple delays work as expected" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // Write as tid = 2
        c.io.rw.thread.poke(2.U)
        c.writeCSR(CSRs.compare_du_wu, "h0000001E".U) // 3 clock cycles
        
        // Step clock to write
        c.clock.step()

        // Check it is active
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(false.B)
        c.io.timer_expire_du_wu(3).expect(true.B)

        // Write as tid = 3
        c.io.rw.thread.poke(3.U)
        c.writeCSR(CSRs.compare_du_wu, "h00000028".U) // 4 clock cycles (from start)
        c.clock.step()

        // Check both tid = 2 and tid = 4 are active
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(false.B)
        c.io.timer_expire_du_wu(3).expect(false.B)

        c.clock.step()

        // tid = 2 should trigger now
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(true.B)
        c.io.timer_expire_du_wu(3).expect(false.B)
        
        c.clock.step()

        // tid = 3 should trigger now
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(true.B)
        c.io.timer_expire_du_wu(3).expect(true.B)
      }
    }
  }

  it should "check that delay less than current time has same effect as nop" in {
    test(csrPriv).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c => 
      timescope {
        // Advance clock a little
        c.clock.step()
        c.clock.step()

        c.writeCSR(CSRs.compare_du_wu, "h0000000A".U) // 1 clock cycle; already expired
        
        // Should have no effect
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(true.B)
        c.io.timer_expire_du_wu(3).expect(true.B)
        c.clock.step()

        // And no effect after another clock cycle
        c.io.timer_expire_du_wu(0).expect(true.B)
        c.io.timer_expire_du_wu(1).expect(true.B)
        c.io.timer_expire_du_wu(2).expect(true.B)
        c.io.timer_expire_du_wu(3).expect(true.B)
      }
    }
  }
}
