/******************************************************************************
Description: Memory-mapped I/O tester.
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

import flexpret.core._

class MMIOCoreTest extends FlatSpec with ChiselScalatestTester {
  behavior of "MMIOCore"

  val config = Seq(
    ("input", 2, 0, MMIOInput),
    ("output", 2, 1, MMIOOutput),
    ("inout", 2, 2, MMIOInout)
  )

  /*
   * Wait for write to be ready.
   */
  def waitForWrite(c: Module, d: DecoupledIO[Data]): Unit = {
    timescope {
      d.valid.poke(false.B)
      while(d.ready.peek().litValue() == 0) {
        c.clock.step()
      }
    }
  }

  it should "prohibit duplicate keys" in {
    intercept[ChiselException] {
      ChiselStage.elaborate { new MMIOCore(Seq(
        ("dup", 2, 0, MMIOInput),
        ("dup", 2, 1, MMIOOutput)
      )) }
    }
  }

  it should "prohibit duplicate offsets" in {
    intercept[ChiselException] {
      ChiselStage.elaborate { new MMIOCore(Seq(
        ("a", 4, 0, MMIOInput),
        ("b", 8, 0, MMIOOutput)
      )) }
    }
  }

  it should "write outputs" in {
    test(new MMIOCore(config)).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      waitForWrite(c, c.io.write)

      timescope {
        c.io.write.valid.poke(true.B)
        c.io.write.bits.addr.poke(0.U)
        c.io.write.bits.data.poke(3.U)
        c.clock.step()
      }

      waitForWrite(c, c.io.write)

      timescope {
        c.io.write.valid.poke(true.B)
        c.io.write.bits.addr.poke(1.U)
        c.io.write.bits.data.poke(2.U)
        c.clock.step()
      }

      waitForWrite(c, c.io.write)

      timescope {
        c.io.write.valid.poke(true.B)
        c.io.write.bits.addr.poke(2.U)
        c.io.write.bits.data.poke(1.U)
        c.clock.step()
      }
      waitForWrite(c, c.io.write)

      c.io.outs.elements("output").expect(2.U)
      c.io.outs.elements("inout").expect(1.U)

      timescope {
        c.io.write.valid.poke(true.B)
        c.io.write.bits.addr.poke(2.U)
        c.io.write.bits.data.poke(3.U)
        c.clock.step()
      }
      waitForWrite(c, c.io.write)
      c.io.outs.elements("inout").expect(3.U)
    }
  }
}
