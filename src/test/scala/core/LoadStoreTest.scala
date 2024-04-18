/******************************************************************************
Description: LoadStore tester.
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
import Core.LoadStore

import flexpret.core.FlexpretConfiguration
import flexpret.core.InstMemConfiguration

class LoadStoreTest extends AnyFlatSpec with ChiselScalatestTester {
  behavior of "LoadStore"

  val threads = 1
  val conf = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, priv=false, features="all")
  def loadStore = new LoadStore()(conf=conf)

  it should "not crash with an invalid request if not enabled" in {
    test(loadStore).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      timescope {
        // No load or store operation with (invalid) SH lingering
        c.io.load.poke(false.B)
        c.io.store.poke(false.B)
        c.io.mem_type.poke(MEM_SH)
        c.io.addr.poke(1.U) // intentionally misaligned
        c.clock.step()
      }
    }
  }
}
