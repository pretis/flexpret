/******************************************************************************
File: util.scala
Description: Various utilities and helper functions
Author: Edward Wang (edwardw@eecs.berkeley.edu)
Contributors: 
License: See LICENSE.txt
******************************************************************************/
package Core

import Chisel._

package object util {
  object uintToBitPatObject {
    implicit def uintToBitPat(x: UInt): BitPat = BitPat(x)
  }
}
