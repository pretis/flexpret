/******************************************************************************
File: main.scala
Description: Main function to elaborate the FlexPRET processor.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package Core

import chisel3._

// Remove this eventually...
import flexpret.core.{VerilatorTop, FpgaTop}
import flexpret.core.FlexpretConfiguration

object CoreMain {

  def verilatorMain(args: Array[String]) : Unit = {
    val configHash = args(0).asUInt(32.W)
    val chiselArgs = args.slice(1, args.length)
    val coreConfig = FlexpretConfiguration.fromFile()

    // Pass configuration to FlexPRET processor.
    (new chisel3.stage.ChiselStage).emitVerilog(new VerilatorTop(coreConfig, configHash), chiselArgs)
  } 
  
  def fpgaMain(args: Array[String]) : Unit = {
    val configHash = args(0).asUInt
    val chiselArgs = args.slice(1, args.length)
    val coreConfig = FlexpretConfiguration.fromFile()

    // Pass configuration to FlexPRET processor.
    (new chisel3.stage.ChiselStage).emitVerilog(new FpgaTop(coreConfig, configHash), chiselArgs)
  } 
    
  def main(args: Array[String]): Unit = {
    if (args.length < 2) {
      sys.error(s"Usage sbt run [target] [configHash]") 
    }
    val target = args(0)
    if (target == "verilator") {
      verilatorMain(args.slice(1, args.length))
    } else if (target == "fpga"){
      fpgaMain(args.slice(1, args.length))
    } else {
      sys.error(s"Unrecognized target $target. Currently only supports `verilator` and `fpga`")
    }
  } 
}
