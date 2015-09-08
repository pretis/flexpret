/******************************************************************************
File: core.scala
Description: FlexPRET Processor (configurable 5-stage RISC-V processor)
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._
import FlexpretConstants._

case class FlexpretConfiguration(threads: Int, flex: Boolean, iMemKB: Int, dMemKB: Int, mul: Boolean, features: String) 
{

  println("features: " + features)
  val mt = threads > 1
  val stats = features == "all"
  val (gpioProtection, memProtection, delayUntil, interruptExpire, externalInterrupt, supportedCauses) =
    if(features == "min")     (false, false, false, false, false, List())
    else if(features == "ex") (mt,    mt,    false, false, true,  List(0,2,3,6,8,9))
    else if(features == "ti") (mt,    mt,    true,  true,  true,  List(0,2,3,6,8,9))
    else                      (mt,    mt,    true,  true,  true,  List(0,1,2,3,6,8,9,10,11))

  // Design Space Exploration
  val regBrJmp = mt && !flex // delay B*, J* 1 cycle to reduce timing path
  val regEvec = true // delay trapping 1 cycle to reduce timing path
  val regSchedule = true // delay DU, WU and schedule update 1 cycle to reduce timing path
  val dedicatedCsrData = true // otherwise wait for pass through ALU
  val iMemCoreRW = true // 'true' required for load/store to ISPM
  val privilegedMode = false // Off until updated to latest compiler..
  //val privilegedMode = true

  // ************************************************************

  // General
  val threadBits = log2Up(threads)
  
  // Datapath
  // If true, allow arbitrary interleaving of threads in pipeline using bypass paths
  // If false, at least four hardware threads must be interleaved in the
  // pipeline (no control unit support for other options)
  val bypassing = (threads < 4) || flex

  // Scheduler
  val roundRobin = !flex
  val initialSlots = List(
    SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_D, SLOT_T0
  )
  val initialTmodes = (0 until threads).map(i => if(i != 0) TMODE_HZ else TMODE_HA)

  // Register File
  val regDepth = 32*threads

  // I-Spm
  val iMemDepth = 256*iMemKB  // 32-bit entries
  val iMemAddrBits = log2Up(iMemDepth) // word addressable
  val iMemHighIndex = log2Up(4*iMemDepth)-1
  val iMemForceEn = false
  val iMemBusRW = false

  // D-Spm
  val dMemDepth = 256*dMemKB //32-bit entries
  val dMemAddrBits = log2Up(4*dMemDepth) // byte addressable
  val dMemHighIndex = log2Up(4*dMemDepth)-1
  val dMemForceEn = false
  val dMemBusRW = false

  // GPIO
  val gpiPortSizes = List(1, 1, 1, 1)
  val gpoPortSizes = List(2, 2, 2, 2)
  val initialGpo = List(
    MEMP_T0, MEMP_SH, MEMP_SH, MEMP_SH
  )

  // Bus
  // upper bits are for thread ID
  val busAddrBits = 10

  // Memory Protection 
  val memRegions = 8
  val iMemLowIndex = iMemHighIndex - log2Up(memRegions) + 1
  val dMemLowIndex = dMemHighIndex - log2Up(memRegions) + 1
  // regions 0..7 (opposite of csr register format)
  val initialIMem = List(
    MEMP_SH, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO, MEMP_RO
  )
  val initialDMem = List(
    MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH, MEMP_SH
  )

  // functionality
  val timeBits = 32
  val timeInc = 10
  require(timeBits <= 32)
  val getTime = delayUntil || interruptExpire

  // TODO: priv fault without loadstore
  // Supported exceptions
  val exceptions = !supportedCauses.isEmpty || interruptExpire || externalInterrupt
  val causes =
    supportedCauses ++
    (if(interruptExpire) List(Causes.ee, Causes.ie) else Nil) ++
    (if(externalInterrupt) List(Causes.external_int) else Nil)

}

class InstMemBusIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  // read/write port
  val addr = UInt(INPUT, conf.iMemAddrBits)
  val enable = Bool(INPUT)
  val data_out = Bits(OUTPUT, 32)
  val write = Bool(INPUT)
  val data_in = Bits(INPUT, 32)
  val ready = Bool(OUTPUT) // doesn't have priority
}

class DataMemBusIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  // read/write port
  val addr = UInt(INPUT, conf.dMemAddrBits-2) // assume word aligned
  val enable = Bool(INPUT)
  val data_out = Bits(OUTPUT, 32)
  val byte_write = Vec.fill(4) { Bool(INPUT) }
  val data_in = Bits(INPUT, 32)
}

class BusIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  val addr = UInt(INPUT, conf.busAddrBits) // assume word aligned
  val enable = Bool(INPUT)
  val data_out = Bits(OUTPUT, 32)
  val write =  Bool(INPUT)
  val data_in = Bits(INPUT, 32)
}

class HostIO() extends Bundle 
{
  val to_host = Bits(OUTPUT, 32)
}

class GPIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  val in = Vec(conf.gpiPortSizes.map(i => Bits(INPUT, i)))
  val out = Vec(conf.gpoPortSizes.map(i => Bits(OUTPUT, i)))
}

class CoreIO(implicit conf: FlexpretConfiguration) extends Bundle
{
  val imem = new InstMemBusIO()
  val dmem = new DataMemBusIO()
  val bus  = new BusIO().flip
  val host = new HostIO()
  val gpio = new GPIO()
  val int_exts = Vec.fill(8) { Bool(INPUT) }
  //val int_exts = Vec.fill(conf.threads) { Bool(INPUT) }
}

class Core(confIn: FlexpretConfiguration) extends Module
{

  implicit val conf = confIn
  
  val io = new CoreIO()

  val control = Module(new Control())
  val datapath = Module(new Datapath())
  val imem = Module(new ISpm())
  //val imem = Module(new ISpm_BRAM())
  val dmem = Module(new DSpm())
  //val dmem = Module(new DSpm_BRAM())
 
  // internal
  datapath.io.control <> control.io
  datapath.io.imem <> imem.io.core
  datapath.io.dmem <> dmem.io.core

  // external
  io.imem <> imem.io.bus
  io.dmem <> dmem.io.bus
  io.bus  <> datapath.io.bus
  io.host <> datapath.io.host
  io.gpio <> datapath.io.gpio
  for(tid <- 0 until conf.threads) {
    datapath.io.int_exts(tid) := io.int_exts(tid)
  } 
  //io.int_exts <> datapath.io.int_exts

}

object CoreMain {
  def main(args: Array[String]): Unit = { 
    
    val confString = args(0)
    val chiselArgs = args.slice(1, args.length)

    val parsed = """(\d+)t(.*)-(\d+)i-(\d+)d.*-(.*)""".r.findFirstMatchIn(confString)
    val coreConfig = new FlexpretConfiguration(
      parsed.get.group(1).toInt,
      !parsed.get.group(2).isEmpty,
      parsed.get.group(3).toInt,
      parsed.get.group(4).toInt,
      confString contains "mul",
      parsed.get.group(5)
      )
      
    // Pass configuration to FlexPRET processor.
    chiselMain( chiselArgs, () => Module(new Core(coreConfig)) )

   }
}
