/******************************************************************************
File: main.scala
Description: Main function to elaborate the FlexPRET processor.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package flexpret

// Remove this eventually...
import flexpret.core.{Core, FlexpretConfiguration}

object CoreMain {
  def main(args: Array[String]): Unit = {

    // Parse the coreCfg string passed as a command line argument
    val coreCfg = if (args.length > 0) {
      FlexpretConfiguration.parseString(args(0))
    } else {
      FlexpretConfiguration.defaultConfig
    }

    // Parse second parameter which is the number of cores
    val nCores = if (args.length > 1) {
      args(1).toInt
    } else {
      1
    }

    println(s"Build SOC with $nCores cores")

    // Extract arguments to pass further to the chisel scala compiler
    val chiselArgs = if (args.length > 2) {
      args.slice(2,args.length)
    } else {
      Array("")
    }

//    val topConfig = TopConfig(
//      coreCfg = coreCfg,
//      nCores = nCores
//    )
//
//    // Pass configuration to FlexPRET processor.
//    (new chisel3.stage.ChiselStage).emitVerilog(new Top(topConfig), chiselArgs)
  }
}
