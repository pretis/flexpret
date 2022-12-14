package flexpret
import chisel3._
import chisel3.util.experimental.loadMemoryFromFileInline // To load program into ISpm
import flexpret.core.{Core, FlexpretConfiguration, GPIO, HostIO, ISpm}
import flexpret.Wishbone.{WishboneMaster}

import wishbone.{S4NoCTopWB}
import s4noc.Config


case class TopConfig(
  coreCfg : FlexpretConfiguration,
  nCores : Int
)


class TopIO(topCfg: TopConfig) extends Bundle {
  val gpio = new GPIO()(topCfg.coreCfg)
  val host = new HostIO()
}

class Top(topCfg: TopConfig) extends Module {
  // Flexpret cores and wb masters
  val cores = for (i <- 0 until topCfg.nCores) yield Module(new Core(topCfg.coreCfg))
  val wbMasters = for (i <- 0 until topCfg.nCores) yield Module(new WishboneMaster(topCfg.coreCfg.busAddrBits)(topCfg.coreCfg))

  // NoC with 4 ports
  val noc = Module(new S4NoCTopWB(Config(4, 2, 2, 2, 32)))
  noc.io.wbPorts.map(_.setDefaults)

  // Termination and printing logic (just for simulation)
  val regCoreDone = RegInit(VecInit(Seq.fill(topCfg.nCores)(false.B)))
  val regCorePrintNext = RegInit(VecInit(Seq.fill(topCfg.nCores)(false.B)))

  for (i <- 0 until topCfg.nCores) {
    val core = cores(i)
    val wb = wbMasters(i)
    // Drove core IO to defaults
    core.io.dmem.driveDefaultsFlipped()
    core.io.imem_bus.driveDefaultsFlipped()
    core.io.int_exts.foreach(_ := false.B)
    // Connect to wb master
    core.io.bus <> wb.busIO

    // Connect WB to NOC
    noc.io.wbPorts(i) <> wb.wbIO

    // Tie off GPIO inputs
    core.io.gpio.in.map(_ := false.B)

    // Initialize instruction scratchpad memory
    loadMemoryFromFileInline(core.imem.get.ispm, s"core${i}.mem")

    // Catch termination from core
    when(core.io.host.to_host === "hdeaddead".U) {
      when(!regCoreDone(i)) {
        printf(cf"Core-${i} is done\n")
      }
      regCoreDone(i) := true.B
    }
    
    // Handle printfs
    when(core.io.host.to_host === "hbaaabaaa".U) {
      regCorePrintNext(i) := true.B
    }.elsewhen(regCorePrintNext(i)) {
      printf(cf"Core-$i: ${core.io.host.to_host}\n")
      regCorePrintNext(i) := false.B
    }
  }

  // Wait until all cores are done
  when(regCoreDone.asUInt().andR()) {
    printf("All cores are done terminating\n")
    assert(false.B, "Program terminated sucessfully")
  }
}
