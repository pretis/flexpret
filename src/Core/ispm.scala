/******************************************************************************
ispm.scala:
  Instruction scratchpad memory.
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

  class ISpm(conf: CoreConfig) extends Module
  {
    val io = new MemIo(conf.iSpmAddrBits)

    // Memory for instruction SPM.
    val mem = Mem(out = Bits(width = XPRLEN), n = (conf.iSpmKBytes*1024/4), seqRead = true)

    // Registered output for sequential read.
    val dout = Reg(outType= Bits(width = XPRLEN) )

    when(io.req.w) {
      // Write.
      mem(io.req.addr) := io.req.wdata
    } 
    .elsewhen(io.req.r)
    {
      // Read.
      dout := mem(io.req.addr)
    }
    io.resp.data := dout

  }

}
