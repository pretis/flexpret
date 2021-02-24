/******************************************************************************
File: util.scala
Description: Various utilities and helper functions
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package flexpret.util

import chisel3._
import chisel3.util.BitPat

object uintToBitPatObject {
  implicit def uintToBitPat(x: UInt): BitPat = BitPat(x)
}
