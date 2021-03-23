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
import flexpret.core.InstMemCoreIO

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

  it should "run a simple recursive program" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        /**
  // set stack pointer
  li sp, 0x20001000

  csrwi 0x51e, 18

  li a0, 10 // 2^10
  call poww
  csrw 0x51e, a0 // tohost
loop:
  j loop

  int poww(uint32_t n) {
      if (n == 0) {
          return 1;
      } else {
          return 2 * poww(n-1);
      }
  }
         */
        prog=scala.collection.immutable.Vector(
  /* 0 */ "h20001137", // lui sp,0x20001
  /* 4 */ "h51e95073", // csrwi 0x51e,18
  /* 8 */ "h00a00513", // li a0,10
  /* c */ "h00c000ef", // jal ra,18 <poww>
  /* 10 */ "h51e51073", // csrw 0x51e,a0
  /* 14 */ "h0000006f", // j 14 <loop>
  /* 18 */ "hfe010113", // addi sp,sp,-32 # 20000fe0 <__global_pointer$+0x1ffff738>
  /* 1c */ "h00112e23", // sw ra,28(sp)
  /* 20 */ "h00812c23", // sw s0,24(sp)
  /* 24 */ "h02010413", // addi s0,sp,32
  /* 28 */ "hfea42623", // sw a0,-20(s0)
  /* 2c */ "hfec42783", // lw a5,-20(s0)
  /* 30 */ "h00079663", // bnez a5,3c <poww+0x24>
  /* 34 */ "h00100793", // li a5,1
  /* 38 */ "h01c0006f", // j 54 <poww+0x3c>
  /* 3c */ "hfec42783", // lw a5,-20(s0)
  /* 40 */ "hfff78793", // addi a5,a5,-1
  /* 44 */ "h00078513", // mv a0,a5
  /* 48 */ "hfd1ff0ef", // jal ra,18 <poww>
  /* 4c */ "h00050793", // mv a5,a0
  /* 50 */ "h00179793", // slli a5,a5,0x1
  /* 54 */ "h00078513", // mv a0,a5
  /* 58 */ "h01c12083", // lw ra,28(sp)
  /* 5c */ "h01812403", // lw s0,24(sp)
  /* 60 */ "h02010113", // addi sp,sp,32
  /* 64 */ "h00008067", // ret
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      var seen1024: Boolean = false

      val cycles=335
      fork {
        imemSim.sim(cycles=cycles)
      } .fork {
        for (i <- 0 to cycles) {
          c.clock.step()
          if (c.io.host.to_host.peek.litValue == 1024) seen1024 = true
        }
      } .join

      assert(seen1024, "Should compute correct result for 2^10")
    }
  }
}
