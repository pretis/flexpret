/******************************************************************************
File: CoreTester.scala
Description: Testbench for FlexPRET processor.
Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
License: See LICENSE.txt
******************************************************************************/
package Core.test

import Core._
import chisel3.iotesters._

class CoreTester(c: Core) extends PeekPokeTester(c) {
  finish
}

object CoreTesterMain {
  def main(args: Array[String]): Unit = {
    if (args.isEmpty) {
      System.err.println("CoreTesterMain usage: configuration_string")
      return
    }
    val confString = args(0)
    val coreConfig = FlexpretConfiguration.parseString(confString)

    // Use Verilator for C++ simulation.
    val extraArgs = Array("--backend-name", "verilator")
    Driver.execute(args ++ extraArgs, () => new Core(coreConfig)) {
      c => new CoreTester(c)
    }
  }
}
