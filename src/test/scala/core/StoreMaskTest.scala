/******************************************************************************
Description: Store mask unit test.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import org.scalatest._

import chisel3._
import chisel3.stage.ChiselStage
import chisel3.util.DecoupledIO

import chiseltest._
import chiseltest.experimental.TestOptionBuilder._

import Core.StoreMask
import Core.FlexpretConstants._

class StoreMaskTest extends FlatSpec with ChiselScalatestTester {
  behavior of "StoreMask"

  /* Simple module for testing purposes */
  class StoreMaskModule extends MultiIOModule {
    val address = IO(Input(UInt(4.W)))
    val memType = IO(Input(UInt(4.W)))
    val mask = IO(Output(UInt(4.W)))
    mask := StoreMask(address, memType)
  }

  it should "store bytes correctly" in {
    test(new StoreMaskModule) { c =>
      c.memType.poke(MEM_SB)
      c.address.poke(4.U)
      c.mask.expect("b0001".U)
      c.address.poke(5.U)
      c.mask.expect("b0010".U)
      c.address.poke(6.U)
      c.mask.expect("b0100".U)
      c.address.poke(7.U)
      c.mask.expect("b1000".U)
    }
  }

  it should "store half-words correctly" in {
    test(new StoreMaskModule) { c =>
      c.memType.poke(MEM_SH)
      c.address.poke(4.U)
      c.mask.expect("b0011".U)
      c.address.poke(6.U)
      c.mask.expect("b1100".U)
      c.address.poke(8.U)
      c.mask.expect("b0011".U)
      c.address.poke(10.U)
      c.mask.expect("b1100".U)
    }
  }

  it should "store words correctly" in {
    test(new StoreMaskModule) { c =>
      c.memType.poke(MEM_SW)
      c.address.poke(0.U)
      c.mask.expect("b1111".U)
      c.address.poke(4.U)
      c.mask.expect("b1111".U)
      c.address.poke(12.U)
      c.mask.expect("b1111".U)
    }
  }
}
