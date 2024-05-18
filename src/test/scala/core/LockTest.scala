package flexpret.core.test

import org.scalatest._

import chisel3._

import chiseltest._
import org.scalatest.flatspec.AnyFlatSpec
import org.scalatest.matchers.should.Matchers

import Core.FlexpretConstants._
import flexpret.core.Lock
import flexpret.core.FlexpretConfiguration
import flexpret.core.InstMemConfiguration


class LockTest extends FlatSpec with ChiselScalatestTester {
  behavior of "Lock"

  val threads = 2
  val conf = FlexpretConfiguration(threads=threads, flex=false, clkFreqMHz=100,
    InstMemConfiguration(bypass=false, sizeKB=512),
    dMemKB=512, mul=false, priv=false, features="all")

  // Acquire lock and expect grant immediatly
  def acquire(c: Lock, tid: Int) = {
    timescope {
      c.io.valid.poke(true.B)
      c.io.acquire.poke(true.B)
      c.io.tid.poke(tid.U)
      c.io.grant.expect(true.B)
      c.clock.step()
    }
  }

  // Acquire lock and expect grant immediatly
  def notAcuire(c: Lock, tid: Int) = {
    timescope {
      c.io.valid.poke(true.B)
      c.io.acquire.poke(true.B)
      c.io.tid.poke(tid.U)
      c.io.grant.expect(false.B)
      c.clock.step()
    }
  }

  def release(c: Lock, tid: Int) = {
    timescope {
      c.io.valid.poke(true.B)
      c.io.acquire.poke(false.B)
      c.io.tid.poke(tid.U)
      c.io.grant.expect(true.B)
      c.clock.step()
    }
  }


  it should "initialize" in {
    test(new Lock()(conf)) { c =>
      c.io.grant.expect(false.B)
    }
  }
  it should "do simpple lock/unlock" in {
    test(new Lock()(conf)) { c =>
      acquire(c,0)
      release(c,0)
    }
  }
  it should "do mutual exclusion" in {
    test(new Lock()(conf)) { c =>
      acquire(c,0)

      for (i <- 0 until 10) {
        notAcuire(c,1)
      }
      release(c,0)
      acquire(c,1)
      release(c,1)
    }
  }
//  it should "Assert when releasing unlocked" in {
//    test(new Lock()(conf)) { c =>
//      release(c,1)
//    }
//  }
//  it should "Assert when releasing other threads lock" in {
//    test(new Lock()(conf)) { c =>
//      acquire(c,0)
//      release(c,1)
//    }
//  }


}
