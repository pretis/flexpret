package flexpret.core
import chisel3._
import chisel3.util.experimental.loadMemoryFromFileInline // Load the contents of ISPM from file



abstract class AbstractTop(cfg: FlexpretConfiguration) extends Module {

    // Write flexpret_config.h and flexpret_config.ld to file
    cfg.writeConfigHeaderToFile("programs/lib/include/flexpret_hwconfig.h")
    cfg.writeLinkerConfigToFile("programs/lib/linker/flexpret_config.ld")
    cfg.writeMakeConfigToFile("./config.mk")

    val core = Module(new Core(cfg))
} 

class VerilatorTopIO(cfg: FlexpretConfiguration) extends Bundle {
    val to_host = Output(Vec(cfg.threads, UInt(32.W)))
}

class VerilatorTop(cfg: FlexpretConfiguration) extends AbstractTop(cfg) {
    val io = IO(new VerilatorTopIO(cfg))
    val regPrintNext = RegInit(VecInit(Seq.fill(cfg.threads) {false.B} ))

    // Drive gpio input of each core to 0 by default
    core.io.gpio.in.map(_ := 0.U)

    // Drive bus input to 0
    core.io.bus.driveDefaults()
    core.io.dmem.driveDefaultsFlipped()
    core.io.imem_bus.driveDefaultsFlipped()
    core.io.int_exts.foreach(_ := false.B)

    // Catch termination from core
    for (tid <- 0 until cfg.threads) {
        io.to_host(tid) := core.io.host.to_host(tid)
    }
}

class FpgaTopIO extends Bundle {
  
}

class FpgaTop(cfg: FlexpretConfiguration) extends AbstractTop(cfg) {

    val io = IO(new FpgaTopIO)
    
    // Drive gpio input of each core to 0 by default
    core.io.gpio.in.map(_ := 0.U)

    // Drive bus input to 0
    core.io.bus.driveDefaults()
    core.io.dmem.driveDefaultsFlipped()
    core.io.imem_bus.driveDefaultsFlipped()
    core.io.int_exts.foreach(_ := false.B)

    // TODO: Probably want to route out some IO or interrupts to the top-level pins
}
