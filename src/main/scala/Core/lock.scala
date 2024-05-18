package flexpret.core
import chisel3._
import chisel3.util._

// A simple implementation of a single lock. No fairness guarantee
// Meant to be used as a spinlock. If a lock acquisition fails,
// the thread will have to retry until it gets it.

class LockIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val valid = Input(Bool())
  val tid = Input(UInt(conf.threadBits.W))
  val acquire = Input(Bool())
  val grant = Output(Bool())

  def driveDefaultsFlipped() = {
    valid := false.B
    tid := 0.U
    acquire := false.B
  }

  def driveDefaults() = {
    grant := false.B
  }
}

class Lock(implicit val conf: FlexpretConfiguration) extends Module {
  val io = IO(new LockIO())
  io.driveDefaults()

  // The lock
  val regLocked = RegInit(false.B)
  val regOwner = RegInit(0.U(conf.threadBits.W))

  // Handle transactions
  when(io.valid) {
    when(io.acquire) {
      // Thread tries to lock
      when(!regLocked) {
        regLocked := true.B
        regOwner := io.tid
        io.grant := true.B
      }.otherwise {
        io.grant := false.B
      }
    }.otherwise {
      assert(regLocked, cf"thread ${io.tid} tried to release unlocked lock")
      when (io.tid === regOwner) {
        regLocked := false.B
        regOwner := 0.U
        io.grant := true.B
      }.otherwise {
        io.grant := false.B
        assert(false.B, cf"thread-${io.tid} tried to release locked owned by thread-${regOwner}")
      }
    }

  }
}
