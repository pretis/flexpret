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

import flexpret.core.{RegisterFile, RegisterFileReadIO, RegisterFileWriteIO}
import flexpret.core.FlexpretConfiguration

class RegisterFileTest extends FlatSpec with ChiselScalatestTester {
  behavior of "RegisterFile"

  val threads = 3
  def registerFile = new RegisterFile(threads=threads)

  /* Write something to the register file */
  def write(c: Module, w: RegisterFileWriteIO, thread: Int, addr: Int, data: UInt): Unit = {
    require(addr < 32)
    timescope {
      w.enable.poke(true.B)
      w.thread.poke(thread.U)
      w.addr.poke(addr.U)
      w.data.poke(data)
      c.clock.step()
    }
  }

  /* Read data from the register file */
  def read(c: Module, b: RegisterFileReadIO, thread: Int, addr: Int) = {
    require(addr < 32)
    timescope {
      b.thread.poke(thread.U)
      b.addr.poke(addr.U)
      c.clock.step()
    }
    b.data.peek().litValue
  }

  /* Write the given register data */
  def writeData(c: RegisterFile, thread: Int, addrDatas: Map[Int, String]): Unit = {
    addrDatas.foreach { case (k, v) => write(c, c.io.write(0), thread, k, v.U) }
  }

  /* Test a thread */
  def testThread(c: RegisterFile, thread: Int, addrDatas: Map[Int, String]): Unit = {
    writeData(c, thread, addrDatas)

    addrDatas.foreach { case (k, v) =>
      assert(read(c, c.io.read(0), thread, k) == v.U.litValue)
      assert(read(c, c.io.read(1), thread, k) == v.U.litValue)
    }
  }

  it should "read back what we read before even if we are reading 0 next" in {
    test(registerFile).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val thread = 0
      val addr = 31
      val data = "hf00df00d".U
      write(c, c.io.write(0), thread, addr, data)

      timescope {
        // The values we are going to check
        c.io.read(0).thread.poke(thread.U)
        c.io.read(0).addr.poke(addr.U)
        c.io.read(1).thread.poke(thread.U)
        c.io.read(1).addr.poke(0.U)
        c.clock.step()

        // Values for the subsequent cycle, shouldn't interfere with the above
        c.io.read(0).thread.poke(thread.U)
        c.io.read(0).addr.poke(0.U)
        c.io.read(1).thread.poke(thread.U)
        c.io.read(1).addr.poke(addr.U)
      }

      // Read data from first set of reads
      c.io.read(0).data.expect(data)
      c.io.read(1).data.expect(0.U)
    }
  }

  it should "write and read in 1 thread" in {
    test(registerFile) { c =>
      // Set a default register to read that is not 0 due to the bug above
      c.io.read(0).addr.poke(31.U)
      c.io.read(1).addr.poke(31.U)

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
      c.io.read(0).addr.poke(31.U)
      c.io.read(1).addr.poke(31.U)

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
    test(registerFile) { c =>
      // Set a default register to read that is not 0 due to the bug above
      c.io.read(0).addr.poke(31.U)
      c.io.read(1).addr.poke(31.U)

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
        keys.foreach { k => assert(read(c, c.io.read(0), thread, k) == addrDatas(k).U.litValue) }
      } .fork {
        keys.reverse.foreach { k => assert(read(c, c.io.read(1), thread, k) == addrDatas(k).U.litValue) }
      } .join
    }
  }

  it should "read and write in the same cycle" in {
    test(registerFile) { c =>
      val thread = 0
      val addr = 31
      val data = "hf00df00d".U
      fork {
        write(c, c.io.write(0), thread, addr, data)
      } .fork {
        assert(read(c, c.io.read(0), thread, addr) == data.litValue)
        assert(read(c, c.io.read(1), thread, addr) == data.litValue)
      } .join
    }
  }

  it should "not leak when reading/writing an invalid thread" in {
    test(registerFile).withAnnotations(Seq(treadle.WriteVcdAnnotation)) { c =>
      val addr = 31
      val data0 = "hf00df00d".U
      val data1 = "hf00df11d".U
      val data2 = "hf00df22d".U
      write(c, c.io.write(0), thread=0, addr=addr, data0)
      write(c, c.io.write(0), thread=1, addr=addr, data1)
      write(c, c.io.write(0), thread=2, addr=addr, data2)

      // Smoke test reading
      assert(read(c, c.io.read(0), 0, addr) == data0.litValue)
      assert(read(c, c.io.read(0), 1, addr) == data1.litValue)
      assert(read(c, c.io.read(0), 2, addr) == data2.litValue)

      // Check that the invalid thread doesn't leak
      {
        val read3 = read(c, c.io.read(0), 3, addr)
        assert(read3 != data0.litValue)
        assert(read3 != data1.litValue)
        assert(read3 != data2.litValue)
      }
      // Try writing to an invalid thread
      write(c, c.io.write(0), thread=3, addr=addr, "haaaaaaaa".U)

      // Check that valid threads aren't affected
      assert(read(c, c.io.read(0), 0, addr) == data0.litValue)
      assert(read(c, c.io.read(0), 1, addr) == data1.litValue)
      assert(read(c, c.io.read(0), 2, addr) == data2.litValue)

      // Check that the invalid thread still doesn't leak
      {
        val read3 = read(c, c.io.read(0), 3, addr)
        assert(read3 != data0.litValue)
        assert(read3 != data1.litValue)
        assert(read3 != data2.litValue)
      }
    }
  }
}
