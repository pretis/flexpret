/******************************************************************************
regfile.scala:
  Register file for all threads.
Authors: 
  Michael Zimmer (mzimmer@eecs.berkeley.edu)
  Chris Shaver (shaver@eecs.berkeley.edu)
Acknowledgement:
  Based on Sodor single-thread 5-stage RISC-V processor by Christopher Celio.
  https://github.com/ucb-bar/riscv-sodor/
******************************************************************************/

package Core
{

import Chisel._
import Node._

import CoreConstants._

class RegisterFileIo(addr_bits: Int) extends Bundle()
{
  val rs1_addr = UInt(INPUT, addr_bits);
  val rs1_data = Bits(OUTPUT, XPRLEN);
  val rs2_addr = UInt(INPUT, addr_bits);
  val rs2_data = Bits(OUTPUT, XPRLEN);
  val waddr    = UInt(INPUT, addr_bits);
  val wdata    = Bits(INPUT, XPRLEN);
  val wen      = Bool(INPUT);
}

class RegisterFile(depth: Int, addr_bits: Int) extends Module
{
  val io = new RegisterFileIo(addr_bits)

  // Use 2, 1R1W SRAMs for a 2R1W SRAM register file.
  val regfile1 = Mem(out = Bits(width = XPRLEN), n = depth, seqRead = true)
  val regfile2 = Mem(out = Bits(width = XPRLEN), n = depth, seqRead = true)

  // Registered output for sequential read.
  val dout1 = Reg(outType= Bits(width = XPRLEN) )
  val dout2 = Reg(outType= Bits(width = XPRLEN) )

  // Write.
  when(io.wen) {
    regfile1(io.waddr) := io.wdata
    regfile2(io.waddr) := io.wdata
  }
  // Read.
  // TODO: best way to handle r0?
  dout1 := regfile1(io.rs1_addr)
  dout2 := regfile2(io.rs2_addr)

  io.rs1_data := dout1
  io.rs2_data := dout2
}

}
