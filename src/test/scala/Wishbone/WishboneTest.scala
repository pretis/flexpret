package flexpret.Wishbone

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec

import flexpret.core.{FlexpretConfiguration, InstMemConfiguration}

class WishboneTest extends AnyFlatSpec with ChiselScalatestTester {

  behavior of "Wishbone"

  val READ_ADDR = 0
  val WRITE_ADDR = 4
  val WRITE_DATA = 8
  val READ_DATA = 12
  val STATUS = 16


  // Write word to the Wishbone master (equivalent of a stw instruction)
  def write(c: WishboneMaster, addr: Int, data: Int): Unit = {
    timescope {
      // Request a write
      c.busIO.data_in.poke(data.U)
      c.busIO.write.poke(true.B)
      c.busIO.enable.poke(true.B)
      c.busIO.addr.poke(addr.U)
      c.clock.step(1)
    }
  }

  // Read word from the wb master (ldw)
  def read(c: WishboneMaster, addr: Int, eData: Int) = {
    timescope {
      c.busIO.write.poke(false.B)
      c.busIO.enable.poke(true.B)
      c.busIO.addr.poke(addr.U)
      c.clock.step()
      c.busIO.data_out.expect(eData.U)
    }
  }

  // Assert a read transaction on the WB interface og the master
  def wbExpectRead(c: WishboneMaster, addr: Int) = {
    c.wbIO.we.expect(false.B)
    c.wbIO.addr.expect(addr.U)
    c.wbIO.wrData.expect(0.U)
    c.wbIO.cyc.expect(true.B)
    c.wbIO.stb.expect(true.B)
    c.wbIO.sel.expect(15.U)
  }

  // Assert a write transaction on the WB interface
  def wbExpectWrite(c: WishboneMaster, addr: Int, data: Int) = {
    c.wbIO.we.expect(true.B)
    c.wbIO.addr.expect(addr.U)
    c.wbIO.wrData.expect(data.U)
    c.wbIO.cyc.expect(true.B)
    c.wbIO.stb.expect(true.B)
    c.wbIO.sel.expect(15.U)
  }

  // Serve a write response back to the WB master
  def serveWriteResp(c: WishboneMaster) = {
    timescope {
      c.wbIO.ack.poke(true.B)
      c.clock.step()
    }
  }

  // Serve a read response back to the WB master
  def serveReadResp(c: WishboneMaster, data: Int) = {
    timescope {
      c.wbIO.ack.poke(true.B)
      c.wbIO.rdData.poke(data.U)
      c.clock.step(1)
    }
  }

  val conf = FlexpretConfiguration(threads = 1, flex = false,
    InstMemConfiguration(bypass = true, sizeKB = 4),
    dMemKB = 256, mul = false, features = "all")

  def wb = new WishboneMaster(conf.busAddrBits)(conf)

  it should "initialize" in {
    test(wb) { c =>
      c.busIO.data_out.expect(0.U)
      c.wbIO.addr.expect(0.U)
      c.wbIO.wrData.expect(0.U)
      c.wbIO.sel.expect(0.U)
      c.wbIO.we.expect(false.B)
      c.wbIO.cyc.expect(false.B)
      c.wbIO.stb.expect(false.B)
    }
  }
  it should "do read" in {
    test(wb).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      write(c, READ_ADDR, 14)
      wbExpectRead(c, 14)
    }
  }

  it should "do write" in {
    test(wb).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      write(c, WRITE_DATA, 42)
      write(c, WRITE_ADDR, 15)
      wbExpectWrite(c, 15, 42)
    }
  }

  it should "Do actual read" in {
    test(wb).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      write(c, READ_ADDR, 14)
      wbExpectRead(c, 14)
      c.clock.step() // Need a clock cycle here
      serveReadResp(c, 62)
      c.clock.step() // Need a clock cycle here also
      read(c, READ_DATA, 62)
    }
  }

  it should "Do status register correctly" in {
    test(wb).withAnnotations(Seq(WriteVcdAnnotation)) { c =>
      read(c, STATUS, 0)
      write(c, READ_ADDR, 14)
      wbExpectRead(c, 14)
      c.clock.step() // Need a clock cycle here
      serveReadResp(c, 62)
      c.clock.step() // Need a clock cycle here also

      read(c, STATUS, 1) // SHould also clear this register
      c.clock.step()
      read(c, STATUS, 0)
      c.clock.step()
      read(c, READ_DATA, 62)
    }
  }



}