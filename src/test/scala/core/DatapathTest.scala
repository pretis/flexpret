/******************************************************************************
Description: Datapath tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import org.scalatest._

import chisel3._

import chiseltest._
import chiseltest.experimental.TestOptionBuilder._

import Core.FlexpretConstants._
import Core.FlexpretConfiguration

import flexpret.core.Control
//import flexpret.core.Datapath
import Core.Datapath
import Core.InstMemCoreIO

class DatapathTest extends FlatSpec with ChiselScalatestTester {
  behavior of "Datapath"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false, iMemKB=512, dMemKB=512, mul=false, features="all")
  def datapath = new Datapath(debug=true)(conf=conf)

  it should "read from the regfile correctly" in {
    // This test confirms that the datapath expects a 1-cycle latency regfile
    // as opposed to 2-cycle.

    test(new MultiIOModule {
      // Hook up the datapath module to a Control module
      val datapathModule = Module(datapath)
      datapathModule.io.gpio <> DontCare
      datapathModule.io.bus <> DontCare
      datapathModule.io.int_exts <> DontCare
      datapathModule.io.dmem.data_out := 0.U

      val imem = IO(Flipped(new InstMemCoreIO()(conf=conf)))
      datapathModule.io.imem <> imem

      val debugIO = IO(chiselTypeOf(datapathModule.io.debugIO.get))
      debugIO <> datapathModule.io.debugIO.get

      val controlModule = Module(new Control()(conf=conf))
      datapathModule.io.control <> controlModule.io
    }) { c =>
      val cycles = 6
      var success = false

      // Every cycle
      // testers2 fork is being too cryptic
      // chiseltest.ThreadOrderDependentException: UInt<32>(IO io_imem_r_data_out in Datapath) -> UInt(IO io_debugIO_rs2_addr in Datapath): Divergent poking / peeking threads
      var alreadyAdded = false
      var lastCycleImem = false

      var lastCycleRS1_1 = -1

      var lastCycleRS2_1 = -1
      (0 until cycles).foreach { _ =>
        lastCycleRS1_1 = c.debugIO.rs1_addr.peek.litValue().toInt
        // For upcoming cycle
        if (lastCycleRS1_1 == 0) {
          c.debugIO.rs1_value.poke(0.U)
        } else if (lastCycleRS1_1 == 1) {
          c.debugIO.rs1_value.poke("h1111_1111".U)
        } else if (lastCycleRS1_1 == 2) {
          c.debugIO.rs1_value.poke("h2222_2222".U)
        }

        lastCycleRS2_1 = c.debugIO.rs2_addr.peek.litValue().toInt
        // For upcoming cycle
        if (lastCycleRS2_1 == 0) {
          c.debugIO.rs2_value.poke(0.U)
        } else if (lastCycleRS2_1 == 1) {
          c.debugIO.rs2_value.poke("h1111_1111".U)
        } else if (lastCycleRS2_1 == 2) {
          c.debugIO.rs2_value.poke("h2222_2222".U)
        }

        // Simulate one instruction add x3, x2, x1 followed by nops
        if (c.imem.r.enable.peek.litValue() > 0) {
          lastCycleImem = true
        }
        if (lastCycleImem) {
          // For upcoming cycle
          if (alreadyAdded) {
            c.imem.r.data_out.poke("h0000_0013".U) // nop = addi x0, x0, 0
          } else {
            c.imem.r.data_out.poke("h0011_01b3".U)
            alreadyAdded = true
          }
        }

        // Check if we ever got the correct result. If we did, we can say that
        // it succeeded.
        if (c.debugIO.exe_alu_result.peek.litValue == "h3333_3333".U.litValue) {
          success = true
        }

        c.clock.step()
        lastCycleImem = false
      }

      assert(success, "Simulation should have read the correct value at the end")
    }
  }
}
