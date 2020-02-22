/******************************************************************************
Description: Register file tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import org.scalatest._

import chisel3._
import chiseltest._
import Core.FlexpretConstants._

//import flexpret.core.RegisterFile
import Core.RegisterFile

class RegisterFileTest extends FlatSpec with ChiselScalatestTester {
  behavior of "RegisterFile"

  it should "work as expected" in {
    test(new MultiIOModule {
      val i = IO(Input(Bool()))
      val o = IO(Output(Bool()))
      o := i
    }) { c =>
      c.clock.step()
    }
  }
}
