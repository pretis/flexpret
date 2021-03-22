/******************************************************************************
Description: Test for a simple core.
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

import flexpret.core.Core
//import flexpret.core.Datapath
import flexpret.core.FlexpretConfiguration
import flexpret.core.InstMemConfiguration
import Core.Datapath
import Core.InstMemCoreIO

class SimpleCoreTest extends FlatSpec with ChiselScalatestTester {
  behavior of "Core (simple config)"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false,
    InstMemConfiguration(bypass=true, sizeKB=4),
    dMemKB=256, mul=false, features="all")
  def core = new Core(conf)

  it should "write a CSR GPIO" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        prog=scala.collection.immutable.Vector(
          /* 0 */ "h00100313", // li t1,1
          /* 4 */ "hcc431073", // csrw 0xcc4,t1
          /* 8 */ "h00000013", // nop
          /* c */ "hcc401073", // csrw 0xcc4,zero
          /* 10 */ "h00000013", // nop
          /* 14 */ "hfedff06f", // j 0
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      var upTransitioned = false
      var downTransitioned = false

      fork {
        imemSim.sim(cycles=50)
      } .fork {
        for (i <- 0 to 50) {
          val prev = c.io.gpio.out(0).peek.litValue
          c.clock.step()
          val after = c.io.gpio.out(0).peek.litValue
          if (after == 1 && prev == 0) upTransitioned = true
          if (after == 0 && prev == 1) downTransitioned = true
        }
      } .join

      assert(upTransitioned, "Must have transitioned up at least once")
      assert(downTransitioned, "Must have transitioned down at least once")
    }
  }

  it should "write the toHost CSR" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        prog=scala.collection.immutable.Vector(
          /* 0 */ "h054c43b7", // lui t2,0x54c4
          /* 4 */ "h4dc38393", // addi t2,t2,1244 # li t2, 88884444
          /* 8 */ "h51e39073", // csrw 0x51e,t2
          /* c */ "h0000006f", // j c <loop>
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      val cycles=25
      fork {
        imemSim.sim(cycles=cycles)
      } .fork {
        for (i <- 0 to cycles) {
          c.clock.step()
        }
        val toHostVal = c.io.host.to_host.peek.litValue
        assert(toHostVal == 88884444)
      } .join
    }
  }
}
