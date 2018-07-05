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
    chisel3.Driver.execute(chiselArgs, () => new Core(coreConfig))
   }
}
