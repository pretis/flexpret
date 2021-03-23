/******************************************************************************
Description: Basic smoke test for jump instructions.
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

import flexpret.core._
import Core.Datapath

class BasicJumpsTest extends FlatSpec with ChiselScalatestTester {
  behavior of "Basic jumps"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false,
    InstMemConfiguration(bypass=true, sizeKB=4),
    dMemKB=256, mul=false, features="all")
  def core = new Core(conf)

  it should "jal" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        /**
  csrwi 0x51e, 16 // tohost
  jal t0, 0xc // note, RISC-V asm syntax specifies this as byte offset
  nop
  nop
  csrw 0x51e, t0
  loop: j loop
         */
        prog=scala.collection.immutable.Vector(
          /* 0 */ "h51e85073", // csrwi 0x51e,16
          /* 4 */ "h008002ef", // jal t0,c <_start+0xc>
          /* 8 */ "h00000013", // nop
          /* c */ "h00000013", // nop
          /* 10 */ "h51e29073", // csrw 0x51e,t0
          /* 14 */ "h0000006f", // j 14 <loop>
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      var correct = false

      val cycles=14
      fork {
        imemSim.sim(cycles=cycles)
      } .fork {
        for (i <- 0 to cycles) {
          c.clock.step()
          if (c.io.host.to_host.peek.litValue == 8) correct = true
        }
      } .join

      assert(correct, "jal should have jumped correctly")
    }
  }

  it should "jalr" in {
    test(core).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val imemSim = new ImemSimulator(
        // Generate with ./scripts/parse_disasm.py
        /**
  csrwi 0x51e, 3 // tohost
  la t1, loopp
  jalr t0, t1, -4
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  csrw 0x51e, t0
  loopp: j loopp
         */
        prog=scala.collection.immutable.Vector(
  /* 0 */ "h51e1d073", // csrwi 0x51e,3
  /* 4 */ "h00000317", // auipc t1,0x0
  /* 8 */ "h03c30313", // addi t1,t1,60 # 40 <loopp>
  /* c */ "hffc302e7", // jalr t0,-4(t1)
  /* 10 */ "h00000013", // nop
  /* 14 */ "h00000013", // nop
  /* 18 */ "h00000013", // nop
  /* 1c */ "h00000013", // nop
  /* 20 */ "h00000013", // nop
  /* 24 */ "h00000013", // nop
  /* 28 */ "h00000013", // nop
  /* 2c */ "h00000013", // nop
  /* 30 */ "h00000013", // nop
  /* 34 */ "h00000013", // nop
  /* 38 */ "h00000013", // nop
  /* 3c */ "h51e29073", // csrw 0x51e,t0
  /* 40 */ "h0000006f", // j 40 <loopp>
        ),
        defaultInstr="h00000067", // jr x0
        clk=c.clock,
        memIO=c.io.imem_core.get
      )

      var correct = false

      val cycles=14
      fork {
        imemSim.sim(cycles=cycles)
      } .fork {
        for (i <- 0 to cycles) {
          c.clock.step()
          if (c.io.host.to_host.peek.litValue == 0x10) correct = true
        }
      } .join

      assert(correct, "jal should have jumped correctly")
    }
  }
}
