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

    val coreCfg = if (args.length > 0) {
      FlexpretConfiguration.parseString(args(0))
    } else {
      FlexpretConfiguration.defaultConfig
    }

    val chiselArgs = if (args.length > 1) {
      args.slice(1,args.length)
    } else {
      Array("")
    }

    val topConfig = TopConfig(
      coreCfg = coreCfg
    )

    // Pass configuration to FlexPRET processor.
    (new chisel3.stage.ChiselStage).emitVerilog(new Top(topConfig), chiselArgs)
  }
}
