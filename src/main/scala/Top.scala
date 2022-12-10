package flexpret
import chisel3._
import flexpret.core.{Core, FlexpretConfiguration, GPIO, HostIO}
import flexpret.Wishbone.WishboneMaster

case class TopConfig(
  coreCfg : FlexpretConfiguration
)


class TopIO(topCfg: TopConfig) extends Bundle {
  val gpio = new GPIO()(topCfg.coreCfg)
  val host = new HostIO()
}

class Top(topCfg: TopConfig) extends MultiIOModule {
  val io = IO(new TopIO(topCfg))
  // FlexPret core
  val core = Module(new Core(topCfg.coreCfg))

  // WB Master connecting FP to memory mapped devices
  val wbMaster = Module(new WishboneMaster(topCfg.coreCfg.busAddrBits)(topCfg.coreCfg))
  core.io.bus <> wbMaster.busIO

  // Connect GPIO pins and "to_host" wires to Top level interface
  io.gpio <> core.io.gpio
  io.host <> core.io.host

  // Drive default values on dmem and the WB device side
  core.io.dmem.driveDefaultsFlipped()
  core.io.imem_bus.driveDefaultsFlipped()
  core.io.int_exts.foreach(_ := false.B)
  wbMaster.wbIO.driveDefaultsFlipped()

}
