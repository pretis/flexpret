package flexpret.core

import chisel3._
import chisel3.util._
import Core.FlexpretConstants._
import Core._

import java.io._
import pureconfig._
import pureconfig.generic.auto._

object FlexpretConfiguration {
  def defaultCfg(): FlexpretConfiguration = {
    new FlexpretConfiguration(
      1,true,
      50,
      InstMemConfiguration(bypass=false, 256),
      24,
      false,
      false,
      "all",
      0,
    )
  }
  def fromFile(): FlexpretConfiguration = {
    ConfigSource.default.loadOrThrow[FlexpretConfiguration]
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
  clkFreqMHz: Int,
  imemConfig: InstMemConfiguration,
  dMemKB: Int,
  mul: Boolean,   // FIXME: Unused, to be removed.
  priv: Boolean,
  features: String,
  uartBaudrate: Int = 115200,
  coreId: Int = 0
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
  val privilegedMode    = priv // Off until updated to latest compiler..

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
  val gpiPortSizes  = List(1, 1, 1, 1)
  val gpoPortSizes  = List(2, 2, 2, 2)

  val initialGpo    = List(
    MEMP_T0, MEMP_SH, MEMP_SH, MEMP_SH
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

  // Bootloader region
  val dMemBtlSize = 0x1000
  val iMemBtlSize = 0x1000

  // functionality
  val clkFreqHz     = clkFreqMHz * 1000000
  val timeBits      = 32
  val nsPerS        = 1000000000
  val timeInc       = nsPerS / clkFreqHz
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
