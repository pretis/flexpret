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

  def imemSimulator(cycles: Int, clk: Clock, memIO: InstMemCoreIO): Unit = {
    var i = 0 // TODO: remove this hideous hack to timeout the imem sim
    while (i < cycles) { i += 1;
      val addr = memIO.r.addr.peek().litValue.toInt
      val enabled = memIO.r.enable.peek().litValue
      clk.step()

      // Generate with ./scripts/parse_disasm.py
      val prog: Seq[String] = scala.collection.immutable.Vector(
        /* 0 */ "h00100313", // li t1,1
        /* 4 */ "hcc431073", // csrw 0xcc4,t1
        /* 8 */ "h00000013", // nop
        /* c */ "hcc401073", // csrw 0xcc4,zero
        /* 10 */ "h00000013", // nop
        /* 14 */ "hfedff06f", // j 0
      )

      val imemData = prog.lift.apply(addr).getOrElse("h00000067") // jr x0
      memIO.r.data_out.poke(imemData.U)
    }
  }

  it should "write a CSR GPIO" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      var upTransitioned = false
      var downTransitioned = false

      fork {
        imemSimulator(cycles=50, c.clock, c.io.imem_core)
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
}
