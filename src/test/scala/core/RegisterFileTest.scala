/******************************************************************************
Description: Register file tester.
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
import Core.FlexpretConfiguration

import flexpret.core.RegisterFile

class RegisterFileTest extends FlatSpec with ChiselScalatestTester {
  behavior of "RegisterFile"

  val threads = 3
  def registerFile = new RegisterFile()(conf=FlexpretConfiguration(threads=threads, flex=false, iMemKB=1024, dMemKB=1024, mul=false, features="all"))

  /* Write something to the register file */
  def write(c: RegisterFile, thread: Int, addr: Int, data: UInt): Unit = {
    require(thread < threads)
    require(addr < 32)
    timescope {
      c.io.rd.enable.poke(true.B)
      c.io.rd.thread.poke(thread.U)
      c.io.rd.addr.poke(addr.U)
      c.io.rd.data.poke(data)
      c.clock.step()
    }
  }

  /* Read something from the register file */
  /* TODO(edwardw): DRY this by making the register read bundle a  */
  def read_rs1(c: RegisterFile, thread: Int, addr: Int) = {
    require(thread < threads)
    require(addr < 32)
    timescope {
      c.io.rs1.thread.poke(thread.U)
      c.io.rs1.addr.poke(addr.U)
      c.clock.step()
    }
    c.io.rs1.data.peek().litValue
  }
  def read_rs2(c: RegisterFile, thread: Int, addr: Int) = {
    require(thread < threads)
    require(addr < 32)
    timescope {
      c.io.rs2.thread.poke(thread.U)
      c.io.rs2.addr.poke(addr.U)
      c.clock.step()
    }
    c.io.rs2.data.peek().litValue
  }

  /* Write the given register data */
  def writeData(c: RegisterFile, thread: Int, addrDatas: Map[Int, String]): Unit = {
    addrDatas.foreach { case (k, v) => write(c, thread, k, v.U) }
  }

  /* Test a thread */
  def testThread(c: RegisterFile, thread: Int, addrDatas: Map[Int, String]): Unit = {
    writeData(c, thread, addrDatas)

    addrDatas.foreach { case (k, v) =>
      assert(read_rs1(c, thread, k) == v.U.litValue)
      assert(read_rs2(c, thread, k) == v.U.litValue)
    }
  }

  it should "read back what we read before even if we are reading 0 next" in {
    test(registerFile) { c =>
      val thread = 0
      val addr = 31
      val data = "hf00df00d".U
      write(c, thread, addr, data)

      // TODO(edwardw): 2 cycle read might be a bug
      timescope {
        // The values we are going to check
        c.io.rs1.thread.poke(thread.U)
        c.io.rs1.addr.poke(addr.U)
        c.io.rs2.thread.poke(thread.U)
        c.io.rs2.addr.poke(0.U)
        c.clock.step()

        // Values for the subsequent cycle, shouldn't interfere with the above
        c.io.rs1.thread.poke(thread.U)
        c.io.rs1.addr.poke(0.U)
        c.io.rs2.thread.poke(thread.U)
        c.io.rs2.addr.poke(addr.U)
      }

      // Read data from first set of reads
      c.io.rs1.data.expect(data)
      c.io.rs2.data.expect(0.U)
    }
  }

  it should "write and read in 1 thread" in {
    test(registerFile) { c =>
      // Set a default register to read that is not 0 due to the bug above
      c.io.rs1.addr.poke(31.U)
      c.io.rs2.addr.poke(31.U)

      val addrDatas = Map(
        8 -> "h88887777",
        9 -> "h99999999",
        16 -> "h1234abcd",
        21 -> "hfafafafa"
      )
      testThread(c, 0, addrDatas)
    }
  }

  it should "not cross-contaminate threads" in {
    test(registerFile) { c =>
      // Set a default register to read that is not 0 due to the bug above
      c.io.rs1.addr.poke(31.U)
      c.io.rs2.addr.poke(31.U)

      (0 until 3).foreach { thread =>
        val addrDatas = Map(
          7 -> ("h7777" + thread.toString * 4),
          8 -> ("h8888" + thread.toString * 4),
          9 -> ("h9999" + thread.toString * 4),
          16 -> ("h1234" + thread.toString * 4),
          21 -> ("hfafa" + thread.toString * 4)
        )
        testThread(c, thread, addrDatas)
      }
    }
  }

  it should "operate read ports independently" in {
    test(registerFile).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      // Set a default register to read that is not 0 due to the bug above
      c.io.rs1.addr.poke(31.U)
      c.io.rs2.addr.poke(31.U)

      val thread = 0
      val addrDatas = Map(
        1 -> "h11111111",
        3 -> "h33333333",
        8 -> "h88887777",
        9 -> "h99999999",
        16 -> "h1234abcd",
        21 -> "hfafafafa",
        24 -> "hf24f2424",
        28 -> "hf2228888"
      )
      writeData(c, thread, addrDatas)

      // Read the data from the two ports in different orders
      val keys = addrDatas.keySet.toSeq
      fork {
        keys.foreach { k => assert(read_rs1(c, thread, k) == addrDatas(k).U.litValue) }
      } .fork {
        keys.reverse.foreach { k => assert(read_rs2(c, thread, k) == addrDatas(k).U.litValue) }
      } .join
    }
  }

  ignore should "read and write in the same cycle" in {
    // ignore this until 2-cycle read is fixed
  }
}
