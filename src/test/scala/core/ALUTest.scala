/******************************************************************************
Description: ALU tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
        Shaokai Lin <shaokai@berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import chisel3._
import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import flexpret.core.ALU
import flexpret.core.ALUTypes

class ALUTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "ALU"

  def alu = new ALU()

  it should "shift correctly when the shift amount uses 5 bits" in {
    test(alu).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      c.io.op1.poke("h80000000".U(32.W))
      c.io.shift.poke("b11111".U(5.W))
      c.io.func.poke(ALUTypes.ShiftRightLogical)
      c.clock.step()
      c.io.result.expect("h00000001".U(32.W))
    }
  }
}
