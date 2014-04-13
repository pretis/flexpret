/******************************************************************************
dspm.scala:
  Data scratchpad memory.
Authors: 
  Michael Zimmer (mzimmer@eecs.berkeley.edu)
  Chris Shaver (shaver@eecs.berkeley.edu)
******************************************************************************/

package Core
{

  import Chisel._
  import Node._
  import Common._
  import CoreConstants._


  class DSpm(conf: CoreConfig) extends BlackBox
  {
    val io = new MemIo(conf.dSpmAddrBits)

    // Memory for data SPM.
    val mem = Mem(out = Bits(width = XPRLEN), n = (conf.dSpmKBytes*1024/4), seqRead = true)

    // Registered output for sequential read.
    val dout = Reg(outType= Bits(width = XPRLEN) )
    io.resp.data := dout

    when(io.req.w) {
      // Write.
      val old = mem(io.req.addr)
      mem(io.req.addr) := Cat(
        Mux(io.req.wmask(3) === Bits(1), io.req.wdata(31, 24), old(31, 24)),
        Mux(io.req.wmask(2) === Bits(1), io.req.wdata(23, 16), old(23, 16)),
        Mux(io.req.wmask(1) === Bits(1), io.req.wdata(15,  8), old(15,  8)),
        Mux(io.req.wmask(0) === Bits(1), io.req.wdata( 7,  0), old( 7,  0))
      )
      //mem.write(io.req.addr, io.req.wdata, FillInterleaved(8, io.req.wmask))
    } .elsewhen(io.req.r) {
      // Read.
      dout := mem(io.req.addr)
    }

  }

  // Alignment and mask for subword writes.
  class StoreHandler extends Module {
    val io = new Bundle {
      val addr = UInt(INPUT, 2)
      val din  = Bits(INPUT, 32)
      val typ  = UInt(INPUT, 3)
      val mask = Bits(OUTPUT, 4)
      val dout = Bits(OUTPUT, 32)
    }

    // Align data for subword writes.
    // If data = ABCD
    // Byte write: DDDD
    // Half-word write: CDCD
    // Word write: ABCD
    io.dout := Cat(
      Mux(io.typ === MSK_B, io.din(7,0), Mux(io.typ === MSK_H, io.din(15,8),io.din(31,24))),
      Mux(io.typ === MSK_W, io.din(23,16), io.din(7,0)),
      Mux(io.typ === MSK_B, io.din(7,0), io.din(15,8)),
      io.din(7,0)
    )

    // Write mask for subword writes depends on address.
    // Byte write: 00->0001, 01->0010, 10->0100, 11->1000
    // Half-word write: 00->0011, 10->1100
    // Word write: 00->1111
    // TODO: check for misaligned addresses.
    io.mask := Mux(io.typ === MSK_B, Bits(1, 1) << io.addr,
      Mux(io.typ === MSK_H, Bits(3, 2) << io.addr,
        Bits(15, 4)))

  }

  // Alignment and sign-extension for subword reads. 
  class LoadHandler extends Module {

    val io = new Bundle {
      val addr = UInt(INPUT, 2)
      val din  = Bits(INPUT, 32)
      val typ  = UInt(INPUT, 3)
      val dout = Bits(OUTPUT, 32)
    }

    // Shift data to move subword reads to lowest bytes.
    // Addr->shift: 00->0, 01->8, 10->16, 11->24
    val shift_amount = Cat(io.addr, Bits(0, 3))
    val shifted = io.din >> shift_amount

    // Zero or sign extend.
    io.dout := MuxCase(shifted, Array(
      (io.typ === MSK_B)  -> Cat(Fill(24, shifted(7)), shifted(7, 0)),
      (io.typ === MSK_BU) -> Cat(Bits(0, 24), shifted(7, 0)),
      (io.typ === MSK_H)  -> Cat(Fill(16, shifted(15)), shifted(15, 0)),
      (io.typ === MSK_HU) -> Cat(Bits(0, 16), shifted(15, 0))))

  }

}
