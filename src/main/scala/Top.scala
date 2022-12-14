package flexpret
import chisel3._
import flexpret.core.{Core, FlexpretConfiguration, GPIO, HostIO}
import flexpret.Wishbone.{WishboneMaster}

import wishbone.{WrappedHello}

case class TopConfig(
  coreCfg : FlexpretConfiguration
)


class TopIO(topCfg: TopConfig) extends Bundle {
  val gpio = new GPIO()(topCfg.coreCfg)
  val host = new HostIO()
}

class Top(topCfg: TopConfig) extends Module {
  val io = IO(new TopIO(topCfg))
  // FlexPret core
  val core = Module(new Core(topCfg.coreCfg))
  core.io.dmem.driveDefaultsFlipped()
  core.io.imem_bus.driveDefaultsFlipped()
  core.io.int_exts.foreach(_ := false.B)

  // WB Master connecting FP to memory mapped devices
  val wbMaster = Module(new WishboneMaster(topCfg.coreCfg.busAddrBits)(topCfg.coreCfg))
  wbMaster.wbIO.setDefaultsFlipped()

  core.io.bus <> wbMaster.busIO

  // Simple Wishbone device for testing
  val wbDevice = Module(new WrappedHello())

  wbMaster.wbIO <> wbDevice.io.port

  // Connect GPIO pins and "to_host" wires to Top level interface
  io.gpio <> core.io.gpio
  io.host <> core.io.host
}
