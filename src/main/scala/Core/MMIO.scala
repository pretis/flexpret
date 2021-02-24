/******************************************************************************
File: MMIO.scala
Description: Memory-mapped I/O. This can connect (eventually) onto the bus
independently from the CSR GPIOs.
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors:
License: See LICENSE.txt
******************************************************************************/
package flexpret

import scala.collection.immutable.ListMap

import chisel3._
import chisel3.util.Decoupled
import chisel3.util.MixedVec
import chisel3.util.MuxLookup
import chisel3.util.Queue

import chisel3.experimental.BundleLiterals._

// Can't define a type at the top level...
package object core {
  sealed trait MMIODirection
  // Appears as an input
  case object MMIOInput extends MMIODirection
  // Appears as an output
  case object MMIOOutput extends MMIODirection
  // Appears as both an input and output, but sharing the same address.
  case object MMIOInout extends MMIODirection

  /**
   * A row of a MMIO memory configuration.
   * Key (must be unique)
   * Number of bits
   * Offset/address
   * Direction
   */
  type MMIORow = (String, Int, Int, MMIODirection)
  object MMIORow {
    /**
     * Check that the given config is valid.
     * i.e. unique keys, non-negative bits, etc.
     */
    def checkConfig(config: Seq[MMIORow]): Unit = {
      val set = scala.collection.mutable.Set[String]()
      val offsets = scala.collection.mutable.Set[Int]()
      config.foreach { case (key, bits, offset, direction) =>
        require(!set(key), s"Set should not contain duplicate key $key")
        set += key
        require(bits > 0, s"Must have 1+ bits (got $bits)")
        require(offset >= 0, s"Must have positive offset (got $offset)")
        require(!offsets(offset), s"Cannot have duplicate offset $offset")
        offsets += offset
      }
    }
  }

  /**
   * Record that actually represents the I/Os going into the module.
   */
  class MMIOIns(val config: Seq[MMIORow]) extends Record {
    MMIORow.checkConfig(config)

    val elements = ListMap[String, Data](config.map { case (key, bits, offset, direction) =>
      direction match {
        // Don't match outputs
        case MMIOOutput => None
        // All else is OK
        case _ => Some(key -> UInt(bits.W))
      }
    }.flatten: _*)

    // Read to an element by address.
    def readByAddress(addr: UInt): UInt = {
      val output = Wire(UInt())
      output := DontCare

      config.filter(_._4 != MMIOOutput).map { case (key, bits, offset, direction) =>
        when (addr === offset.U) {
          output := elements(key)
        }
      }

      output
    }

    override def cloneType: this.type = new MMIOIns(config).asInstanceOf[this.type]
  }
  /**
   * Record that actually represents the I/Os going into the module.
   */
  class MMIOOuts(val config: Seq[MMIORow]) extends Record {
    MMIORow.checkConfig(config)

    val elements = ListMap[String, Data](config.map { case (key, bits, offset, direction) =>
      direction match {
        // Don't match inputs
        case MMIOInput => None
        // All else is OK
        case _ => Some(key -> UInt(bits.W))
      }
    }.flatten: _*)

    // Write to an element by address.
    def writeByAddress(addr: UInt, data: UInt): Unit = {
      config.filter(_._4 != MMIOInput).map { case (key, bits, offset, direction) =>
        when (addr === offset.U) {
          elements(key) := data
        }
      }
    }

    override def cloneType: this.type = new MMIOOuts(config).asInstanceOf[this.type]
  }

  // I/O bundle for making a write request.
  class MMIOWriteIO extends Bundle {
    val addr = UInt(32.W)
    val data = UInt(32.W)
  }

  // I/O bundle for the response to a read request.
  class MMIOReadRespIO extends Bundle {
    val addr = UInt(32.W)
    val data = UInt(32.W)
  }

  /**
   * Memory-mapped I/O that accepts requests via a decoupled interface.
   * 32-bit interface.
   * @param config Memory-mapped I/O config.
   */
  class MMIOCore(
    val config: Seq[MMIORow]
  ) extends Module {
    MMIORow.checkConfig(config)

    val io = IO(new Bundle {
      // The actual external-facing I/Os.
      val ins = Input(new MMIOIns(config))
      val outs = Output(new MMIOOuts(config))

      // Interface for making a read request.
      // Address requested
      val readReq = Flipped(Decoupled(UInt(32.W)))
      val readResp = Decoupled(new MMIOReadRespIO)

      // Interface for making a write request.
      val write = Flipped(Decoupled(new MMIOWriteIO))
    })

    // Registers for outputs
    val output_regs = RegInit(0.U.asTypeOf(new MMIOOuts(config)))

    // Connect them to the actual I/Os
    io.outs := output_regs

    // Handle the reading interface
    val readRespQueue = Module(new Queue(new MMIOReadRespIO, 4)) // parametrize?
    io.readResp <> readRespQueue.io.deq
    // We can handle incoming requests when we have space in the output queue
    io.readReq.ready := readRespQueue.io.enq.ready
    when (io.readReq.fire()) {
      // Read from IO and enqueue into output queue.
      val addr = io.readReq.bits
      val resp = Wire(new MMIOReadRespIO)
      resp.addr := addr
      resp.data := io.ins.readByAddress(addr)

      readRespQueue.io.enq.enq(resp)
      assert(readRespQueue.io.enq.fire())
    } .otherwise {
      readRespQueue.io.enq.noenq()
    }

    // Handle the writing interface
    io.write.ready := true.B
    when (io.write.valid) {
      output_regs.writeByAddress(io.write.bits.addr, io.write.bits.data)
    }
  }
}
