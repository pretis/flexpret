package flexpret.core
import chisel3._
import chisel3.util.MixedVec
import chisel3.util.experimental.loadMemoryFromFileInline // Load the contents of ISPM from file
import flexpret.{WishboneBus, WishboneMaster, WishboneUart}

abstract class AbstractTop(cfg: FlexpretConfiguration) extends Module {

    /** 
     * Write the configuration to various files so software has access to it.
     * 
     * flexpret_hwconfig.h  contains hardware configuration of the built CPU in
     *                      the form of C macros
     * flexpret_hwconfig.ld contains much of the same information, just in the
     *                      linker script language
     * hwconfig.mk          again contains the same information, but in the Makefile
     *                      language
     * 
     * The reason for generating the same information in all these languages is
     * so the software developer has readily access to it where ever it may be
     * useful.
     */
    cfg.writeHeaderConfigToFile("./programs/lib/include/flexpret_hwconfig.h")
    cfg.writeLinkerConfigToFile("./programs/lib/linker/flexpret_hwconfig.ld")
    cfg.writeMakeConfigToFile("./hwconfig.mk")

    val core = Module(new Core(cfg))

    val wbMaster = Module(new WishboneMaster(cfg.busAddrBits)(cfg))
    val wbUart   = Module(new WishboneUart()(cfg))
    val wbBus    = Module(new WishboneBus(cfg.busAddrBits, Seq(4)))

    // Connect WB bus to FlexPRET bus
    //core.io.bus.driveDefaults()
    wbMaster.busIO <> core.io.bus
    //core.io.bus.addr := 

    // Connect WB bus to WB master
    wbBus.io.wbMaster <> wbMaster.wbIO

    // Connect WB bus to WB UART
    wbBus.io.wbDevices(0) <> wbUart.io.port
} 

class VerilatorTopIO(cfg: FlexpretConfiguration) extends Bundle {
    val gpio = new GPIO()(cfg)
    val uart = new Bundle {
        val rx = Input(Bool())
        val tx = Output(Bool())
    }
    val to_host = Output(Vec(cfg.threads, UInt(32.W)))
    val int_exts = Input(Vec(cfg.threads, Bool()))
    val imem_store = Output(Bool())
}

class VerilatorTop(cfg: FlexpretConfiguration) extends AbstractTop(cfg) {
    val io = IO(new VerilatorTopIO(cfg))
    val regPrintNext = RegInit(VecInit(Seq.fill(cfg.threads) {false.B} ))

    io.gpio <> core.io.gpio

    // Connect rx tx signals
    io.uart.tx := wbUart.ioUart.tx
    wbUart.ioUart.rx := io.uart.rx
    
    core.io.int_exts <> io.int_exts

    // Drive bus input to 0
    core.io.dmem.driveDefaultsFlipped()
    core.io.imem_bus.driveDefaultsFlipped()

    // Catch termination from core
    for (tid <- 0 until cfg.threads) {
        io.to_host(tid) := core.io.host.to_host(tid)
    }

    io.imem_store := core.io.imem_store
}

class FpgaTopIO(cfg: FlexpretConfiguration) extends Bundle {
    val gpio = new GPIO()(cfg)
    val uart = new Bundle {
        val rx = Input(Bool())
        val tx = Output(Bool())
    }
    val int_exts = Input(Vec(cfg.threads, Bool()))
}

class FpgaTop(cfg: FlexpretConfiguration) extends AbstractTop(cfg) {
    val io = IO(new FpgaTopIO(cfg))
    
    io.gpio <> core.io.gpio
    core.io.int_exts <> io.int_exts

    // Connect rx tx signals
    io.uart.tx := wbUart.ioUart.tx
    wbUart.ioUart.rx := io.uart.rx

    // Drive bus input to 0
    core.io.dmem.driveDefaultsFlipped()
    core.io.imem_bus.driveDefaultsFlipped()
}
