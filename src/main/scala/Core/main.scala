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
import flexpret.core.Core
import flexpret.core.FlexpretConfiguration

object CoreMain {
  def main(args: Array[String]): Unit = {
    val confString = args(0)
    val chiselArgs = args.slice(1, args.length)
    val coreConfig = FlexpretConfiguration.parseString(confString)

    // Pass configuration to FlexPRET processor.
    chisel3.Driver.execute(chiselArgs, () => new Core(coreConfig))
  }
}
