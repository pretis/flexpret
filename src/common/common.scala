package Common
{
  import Chisel._
  import Node._

class MemIo(addrBits: Int) extends Bundle
{
  val req = new Bundle {
    val addr = UInt(INPUT, addrBits)
    val wdata = Bits(INPUT, 32)
    val wmask = Bits(INPUT, 4)
    val r = Bool(INPUT)
    val w = Bool(INPUT)
  }
  val resp = new Bundle {
    val data = Bits(OUTPUT, 32)
  }
}


}
