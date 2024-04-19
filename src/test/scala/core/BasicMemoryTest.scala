/******************************************************************************
Description: Basic smoke test for memory instructions.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import Core.FlexpretConstants._

import flexpret.core._

class BasicMemoryTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "Basic memory instructions"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=true, sizeKB=4),
    dMemKB=256, mul=false, priv=false, features="all")
  def core = new Core(conf, "h00000000".asUInt(32.W))

  it should "lw/sw" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        /**
  // set stack pointer
  li sp, 0x20001000

  csrwi 0x530, 8

  li t0, 0x1234face
  sw t0, -16(sp)

  li t1, -0xface
  add t0, t0, t1
  sw t0, 28(sp)

  not t1, zero
  sw t1, 4(sp)

  addi sp, sp, 4

  mv t2, zero
  mv t1, zero
  mv t0, zero

  lw t0, -20(sp)
  lw t1, 24(sp)
  lw t2, 0(sp)
  csrw 0x530, t0
  csrw 0x530, t1
  csrw 0x530, t2
  loopp: j loopp
         */
        prog=scala.collection.immutable.Vector(
  /* 0 */ "h20001137", // lui sp,0x20001
  /* 4 */ "h53045073", // csrwi 0x530,8
  /* 8 */ "h123502b7", // lui t0,0x12350
  /* c */ "hace28293", // addi t0,t0,-1330 # 1234face <__global_pointer$+0x1234e1ba>
  /* 10 */ "hfe512823", // sw t0,-16(sp) # 20000ff0 <__global_pointer$+0x1ffff6dc>
  /* 14 */ "hffff0337", // lui t1,0xffff0
  /* 18 */ "h53230313", // addi t1,t1,1330 # ffff0532 <__global_pointer$+0xfffeec1e>
  /* 1c */ "h006282b3", // add t0,t0,t1
  /* 20 */ "h00512e23", // sw t0,28(sp)
  /* 24 */ "hfff04313", // not t1,zero
  /* 28 */ "h00612223", // sw t1,4(sp)
  /* 2c */ "h00410113", // addi sp,sp,4
  /* 30 */ "h00000393", // li t2,0
  /* 34 */ "h00000313", // li t1,0
  /* 38 */ "h00000293", // li t0,0
  /* 3c */ "hfec12283", // lw t0,-20(sp)
  /* 40 */ "h01812303", // lw t1,24(sp)
  /* 44 */ "h00012383", // lw t2,0(sp)
  /* 48 */ "h53029073", // csrw 0x530,t0
  /* 4c */ "h53031073", // csrw 0x530,t1
  /* 50 */ "h53039073", // csrw 0x530,t2
  /* 54 */ "h0000006f", // j 54 <loopp>
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      var seen1 = false // 0x1234face
      var seen2 = false // 0x12340000
      var seen3 = false // 0xffffffff

      val cycles=30
      fork {
        imemSim.sim(cycles=cycles)
      } .fork {
        for (i <- 0 to cycles) {
          c.clock.step()
          if (!seen1) {
            if (c.io.host.to_host.peek().litValue == 0x1234face) seen1 = true
          } else if (!seen2) {
            if (c.io.host.to_host.peek().litValue == 0x12340000) seen2 = true
          } else {
            if (c.io.host.to_host.peek().litValue == BigInt("ffffffff", 16)) seen3 = true
          }
        }
      } .join

      assert(seen1 && seen2 && seen3, "lw/sw should work correctly")
    }
  }
}
