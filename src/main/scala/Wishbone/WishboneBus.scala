package flexpret

import chisel3._
import chisel3.util._

import wishbone.WishboneIO

// Wishbone bus inspired by Martonis wbPlumbing repo: https://github.com/Martoni/WbPlumbing/blob/master/src/main/scala/wbplumbing/wbplumbing.scala

class WishboneBusIO(
  val masterWidth: Int,
  val deviceWidths: Seq[Int]
) extends Bundle {
  val wbMaster = Flipped(new WishboneIO(masterWidth))
  val wbDevices = MixedVec(deviceWidths.map{i => new WishboneIO(i)})

  // Master address must be big enough
  require(masterWidth > deviceWidths.sum)
  // ALl slaves of same width
  for (w <- deviceWidths) require(w == deviceWidths.head)
}

class WishboneBus(
  val masterWidth: Int,
  val deviceWidths: Seq[Int]
) extends Module {
  val io = IO(new WishboneBusIO(masterWidth, deviceWidths))
  io.wbMaster.setDefaultsFlipped()
  io.wbDevices.map(_.setDefaults())

  var devAddr = Seq(0)
  for ((dev,i) <- io.wbDevices.zipWithIndex) {
    // Calculate address range of this device
    devAddr = devAddr ++ Seq(devAddr.last + (1 << deviceWidths(i)))
    dev.addr := io.wbMaster.addr
    dev.wrData := io.wbMaster.wrData

    // Only connect wires when the device is being addressed
    when(io.wbMaster.cyc
      && io.wbMaster.stb
      && io.wbMaster.addr >= devAddr(devAddr.length-2).U
      && io.wbMaster.addr < devAddr.last.U
    ) {
      dev.we := io.wbMaster.we
      dev.stb := io.wbMaster.stb
      dev.cyc := io.wbMaster.cyc
      io.wbMaster.rdData := dev.rdData
      io.wbMaster.ack := dev.ack
    }
  }
}
