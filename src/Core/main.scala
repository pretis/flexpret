/******************************************************************************
File: main.scala
Description: Main function to elaborate the FlexPRET processor.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package Core

import chisel3._

object CoreMain {
  def main(args: Array[String]): Unit = {
    if (args.isEmpty) {
      System.err.println("CoreMain usage: configuration_string [chisel arg] [chisel arg] [...]")
      return
    }
    val confString = args(0)
    val chiselArgs = args.slice(1, args.length)
    val coreConfig = FlexpretConfiguration.parseString(confString)

    // Pass configuration to FlexPRET processor.
    chisel3.Driver.execute(chiselArgs, () => new Core(coreConfig))
  }
}
