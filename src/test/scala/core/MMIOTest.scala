/******************************************************************************
Description: Memory-mapped I/O tester.
Author: Edward Wang <edwardw@eecs.berkeley.edu>
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret.core.test

import chisel3._
import chisel3.stage.ChiselStage
import chisel3.util.DecoupledIO

import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import flexpret.core._

class MMIOCoreTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "MMIOCore"

  val config = Seq(
    ("input", 2, 0, MMIOInput),
    ("output", 2, 1, MMIOOutput),
    ("inout", 2, 2, MMIOInout)
  )

  /*
   * Wait for a decoupled to be ready.
   */
  def waitForDecoupled(c: Module, d: DecoupledIO[Data]): Unit = {
    timescope {
      d.valid.poke(false.B)
      while(d.ready.peek().litValue == 0) {
        c.clock.step()
      }
    }
  }

  it should "prohibit duplicate keys" in {
    intercept[java.lang.IllegalArgumentException] {
      ChiselStage.elaborate { new MMIOCore(Seq(
        ("dup", 2, 0, MMIOInput),
        ("dup", 2, 1, MMIOOutput)
      )) }
    }
  }

  it should "prohibit duplicate offsets" in {
    intercept[java.lang.IllegalArgumentException] {
      ChiselStage.elaborate { new MMIOCore(Seq(
        ("a", 4, 0, MMIOInput),
        ("b", 8, 0, MMIOOutput)
      )) }
    }
  }

  /**
   * Test that reading inputs works.
   */
  def testReads(c: MMIOCore): Unit = {
    timescope {
      c.io.ins.elements("input").poke(3.U)
      c.io.ins.elements("inout").poke(1.U)
      c.io.readResp.ready.poke(false.B)

      waitForDecoupled(c, c.io.readReq)

      c.io.readReq.valid.poke(true.B)
      c.io.readReq.bits.poke(2.U)
      c.clock.step()

      waitForDecoupled(c, c.io.readReq)

      c.io.readReq.valid.poke(true.B)
      c.io.readReq.bits.poke(0.U)
      c.clock.step()
    }

    timescope {
      c.io.readResp.ready.poke(true.B)
      while(c.io.readResp.valid.peek().litValue == 0) {
        c.clock.step()
      }
      c.io.readResp.bits.addr.expect(2.U)
      c.io.readResp.bits.data.expect(1.U)
      c.clock.step()
      while(c.io.readResp.valid.peek().litValue == 0) {
        c.clock.step()
      }
      c.io.readResp.bits.addr.expect(0.U)
      c.io.readResp.bits.data.expect(3.U)
    }
  }

  def testWrites(c: MMIOCore): Unit = {
    waitForDecoupled(c, c.io.write)

    timescope {
      c.io.write.valid.poke(true.B)
      c.io.write.bits.addr.poke(0.U)
      c.io.write.bits.data.poke(3.U)
      c.clock.step()
    }

    waitForDecoupled(c, c.io.write)

    timescope {
      c.io.write.valid.poke(true.B)
      c.io.write.bits.addr.poke(1.U)
      c.io.write.bits.data.poke(2.U)
      c.clock.step()
    }

    waitForDecoupled(c, c.io.write)

    timescope {
      c.io.write.valid.poke(true.B)
      c.io.write.bits.addr.poke(2.U)
      c.io.write.bits.data.poke(1.U)
      c.clock.step()
    }
    waitForDecoupled(c, c.io.write)

    c.io.outs.elements("output").expect(2.U)
    c.io.outs.elements("inout").expect(1.U)

    timescope {
      c.io.write.valid.poke(true.B)
      c.io.write.bits.addr.poke(2.U)
      c.io.write.bits.data.poke(3.U)
      c.clock.step()
    }
    waitForDecoupled(c, c.io.write)
    c.io.outs.elements("inout").expect(3.U)
  }

  it should "read inputs" in {
    test(new MMIOCore(config)).withAnnotations(Seq(treadle.WriteVcdAnnotation)).apply(testReads)
  }

  it should "write outputs" in {
    test(new MMIOCore(config)).withAnnotations(Seq(treadle.WriteVcdAnnotation)).apply(testWrites)
  }

  it should "read and write at the same time" in {
    test(new MMIOCore(config)).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      fork {
        testReads(c)
      } .fork {
        testWrites(c)
      } .join
    }
  }
}
