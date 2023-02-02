/******************************************************************************
File: core.scala
Description: FlexPRET Processor (configurable 5-stage RISC-V processor)
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package flexpret.core

import chisel3._
import chisel3.util.log2Ceil
import chisel3.util.MixedVec
import chisel3.experimental.chiselName

// Remove this eventually
import Core._
import Core.FlexpretConstants._

object FlexpretConfiguration {
  /**
   * Parse a given configuration string into a FlexpretConfiguration.
   */
  def parseString(confString: String, coreId: Int=0): FlexpretConfiguration = {
    val parsed = """(\d+)t(.*)-(\d+)i-(\d+)d.*-(.*)""".r.findFirstMatchIn(confString)
    new FlexpretConfiguration(
      parsed.get.group(1).toInt,
      !parsed.get.group(2).isEmpty,
      InstMemConfiguration(bypass=false, parsed.get.group(3).toInt),
      parsed.get.group(4).toInt,
      confString contains "mul",
      parsed.get.group(5),
      coreId
    )
  }

  def defaultConfig: FlexpretConfiguration = {
    new FlexpretConfiguration(threads=1, flex=false,
      InstMemConfiguration(bypass=false, sizeKB=4),
      dMemKB=256, mul=false, features="all", coreId=0)
  }
}

case class InstMemConfiguration(
  // Set to true to hook up instruction memory from outside the core
  bypass: Boolean,
  // Size of the instruction memory (KB) - for memory mapping purposes
  sizeKB: Int
) {
  require(sizeKB >= 0)
}

case class FlexpretConfiguration(
  threads: Int,
  flex: Boolean,
  imemConfig: InstMemConfiguration,
  dMemKB: Int,
  mul: Boolean,   // FIXME: Unused, to be removed.
  features: String,
  coreId: Int
) {
  println("features: " + features)
  val mt = threads > 1
  val stats = features == "all"
  val (gpioProtection, memProtection, delayUntil, interruptExpire, externalInterrupt, supportedCauses) =
    if (features == "min") (false, false, false, false, false, List())
    else if (features == "ex") (mt, mt, false, false, true, List(0, 2, 3, 6, 8, 9))
    else if (features == "ti") (mt, mt, true, true, true, List(0, 2, 3, 6, 8, 9))
    else (mt, mt, true, true, true, List(0, 1, 2, 3, 6, 8, 9, 10, 11))

  // Design Space Exploration
  val regBrJmp          = mt && !flex // delay B*, J* 1 cycle to reduce timing path
  val regEvec           = true // delay trapping 1 cycle to reduce timing path
  val regSchedule       = true // delay DU, WU and schedule update 1 cycle to reduce timing path
  val dedicatedCsrData  = true // otherwise wait for pass through ALU
  val iMemCoreRW        = true // 'true' required for load/store to ISPM
  val privilegedMode    = false // Off until updated to latest compiler..

  // ************************************************************

  // General
  // TODO(edwardw): test this assumption and remove the use of the deprecated log2Up
  //require(threads > 0, "Cannot have zero hardware threads")
  val threadBits    = if (Chisel.log2Up(threads) == 0) 1 else Chisel.log2Up(threads)

  // Datapath
  // If true, allow arbitrary interleaving of threads in pipeline using bypass paths
  // If false, at least four hardware threads must be interleaved in the
  // pipeline (no control unit support for other options)
  val bypassing     = (threads < 4) || flex

  // Scheduler
  val roundRobin    = !flex
  // At the beginning, only T0 is specified in the schedule.
  val initialSlots  = List(
    SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_T0
  )
  // At the beginning, all threads are HRTTs,
  // and T0 is the only active HRTT.
  val initialTmodes = (0 until threads).map(i => if (i != 0) TMODE_HZ else TMODE_HA)

  // I-Spm
  val iMemDepth     = 256 * imemConfig.sizeKB   // 32-bit entries
  val iMemAddrBits  = log2Ceil(4 * iMemDepth)   // byte addressable
  val iMemHighIndex = log2Ceil(4 * iMemDepth) - 1
  val iMemForceEn   = false
  val iMemBusRW     = false

  // D-Spm
  val dMemDepth     = 256 * dMemKB              // 32-bit entries
  val dMemAddrBits  = log2Ceil(4 * dMemDepth)   // byte addressable
  val dMemHighIndex = log2Ceil(4 * dMemDepth) - 1
  val dMemForceEn   = false
  val dMemBusRW     = false

  // GPIO
  val gpiPortSizes  = List(8, 8, 8, 8)
  val gpoPortSizes  = List(8, 8, 8, 8)
  val initialGpo    = List(
    MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH
  )

  // Bus
  // upper bits are for thread ID
  val busAddrBits   = 10

  // Memory Protection
  val memRegions    = 8
  val iMemLowIndex  = iMemHighIndex - log2Ceil(memRegions) + 1
  val dMemLowIndex  = dMemHighIndex - log2Ceil(memRegions) + 1
  // regions 0..7 (opposite of csr register format)
  val initialIMem   = List(
    MEMP_SH, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO
  )
  val initialDMem   = List(
    MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH
  )

  // functionality
  val timeBits      = 32
  val timeInc       = 20
  require(timeBits <= 32)
  val getTime       = delayUntil || interruptExpire
  val hwLock        = true

  // TODO: priv fault without loadstore
  // Supported exceptions
  val exceptions = !supportedCauses.isEmpty || interruptExpire || externalInterrupt
  val causes =
    supportedCauses ++
      (if (interruptExpire) List(Causes.ee, Causes.ie) else Nil) ++
      (if (externalInterrupt) List(Causes.external_int) else Nil)

}

class InstMemBusIO(implicit conf: FlexpretConfiguration) extends Bundle {
  // read/write port
  val addr = Input(UInt(conf.iMemAddrBits.W))
  val enable = Input(Bool())
  val data_out = Output(UInt(32.W))
  val write = Input(Bool())
  val data_in = Input(UInt(32.W))
  val ready = Output(Bool()) // doesn't have priority

  def driveDefaultsFlipped() = {
    addr := 0.U
    enable := false.B
    write := false.B
    data_in := 0.U
  }
}

class DataMemBusIO(implicit conf: FlexpretConfiguration) extends Bundle {
  // read/write port
  val addr = Input(UInt((conf.dMemAddrBits - 2).W)) // assume word aligned
  val enable = Input(Bool())
  val data_out = Output(UInt(32.W))
  val byte_write = Input(Vec(4, Bool()))
  val data_in = Input(UInt(32.W))

  def driveDefaultsFlipped() = {
    addr := 0.U
    enable := false.B
    data_in := 0.U
    byte_write.map(_ := false.B)
  }
}

class BusIO(implicit conf: FlexpretConfiguration) extends Bundle {
  val addr = Input(UInt(conf.busAddrBits.W)) // assume word aligned
  val enable = Input(Bool())
  val data_out = Output(UInt(32.W))
  val write = Input(Bool())
  val data_in = Input(UInt(32.W))

  def driveDefaults(): Unit = {
    data_out := 0.U
  }
}

class HostIO() extends Bundle {
  val to_host = Output(UInt(32.W))
}

class GPIO(implicit conf: FlexpretConfiguration) extends Bundle {
  val in = MixedVec(conf.gpiPortSizes.map(i => Input(UInt(i.W))).toSeq)
  val out = MixedVec(conf.gpoPortSizes.map(i => Output(UInt(i.W))).toSeq)
}

class CoreIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val imem_core = if (conf.imemConfig.bypass) Some(Flipped(new InstMemCoreIO)) else None
  val imem_bus = new InstMemBusIO
  val dmem = new DataMemBusIO()
  val bus = Flipped(new BusIO())
  val host = new HostIO()
  val gpio = new GPIO()
  val int_exts = Input(Vec(8, Bool()))
  //val int_exts = Input(Vec(conf.threads, Bool()))
}

@chiselName
class Core(val confIn: FlexpretConfiguration) extends Module {
  implicit val conf = confIn

  val io = IO(new CoreIO)

  val control = Module(new Control())
  val datapath = Module(new Datapath())
  val imem = if (conf.imemConfig.bypass) None else Some(Module(new ISpm()))
  val dmem = Module(new DSpm())
  //val dmem = Module(new DSpm_BRAM())

  // internal
  datapath.io.control <> control.io
  datapath.io.imem <> (imem match {
    case Some(imem_module) => imem_module.io.core
    case _ => io.imem_core.get
  })
  datapath.io.dmem <> dmem.io.core

  // external
  io.imem_bus <> (imem match {
    case Some(imem_module) => imem_module.io.bus
    case _ => DontCare
  })
  io.dmem <> dmem.io.bus
  io.bus <> datapath.io.bus
  io.host <> datapath.io.host
  io.gpio <> datapath.io.gpio
  for (tid <- 0 until conf.threads) {
    datapath.io.int_exts(tid) := io.int_exts(tid)
  }
  //io.int_exts <> datapath.io.int_exts

}
