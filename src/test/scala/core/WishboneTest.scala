package flexpret.core.test

import flexpret.core.{WishboneConfig, WishboneFlexpretMaster, FlexpretConfiguration, InstMemConfiguration}
import chisel3._
import org.scalatest._
import chiseltest._
import chisel3.experimental.BundleLiterals._

class TestWishbone extends FlatSpec with ChiselScalatestTester {

  behavior of "Wishbone"

  def write(c: WishboneFlexpretMaster, addr: Int, data: Int): Unit = {
    c.busIO.data_in.poke(data.U)
    c.busIO.write.poke(true.B)
    c.busIO.enable.poke(true.B)
    c.busIO.addr.poke(addr.U)
  }

  def read(c: WishboneFlexpretMaster, idx: Int, addr: Int, expect: Int) = {
  }

  val cfg = WishboneConfig(numDevices = 8, numMasters = 1)
  val conf = FlexpretConfiguration(threads=1, flex=false,
    InstMemConfiguration(bypass=true, sizeKB=4),
    dMemKB=256, mul=false, features="all")

  def wb = new WishboneFlexpretMaster(cfg)(conf)

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
}