package flexpret.core
import chisel3._
import chisel3.util._

// A simple implementation of a single lock.
// Not optimized for space, but rather for clarity
// The module should be linked with a CSR.
// When a thread writes LOCK_QCQUIRE to that CSR we interpret it as a lock acquire
// it will receive a "grant" if the lock is available.
// If the grant signal is not asserted the CSR logic must put this thread to sleep
// When a lock is released we can let a waiting thread acquire it. This is signalled
// through the LockThreadReleaseIO port. The tid asserted there must be handled by the
// CSR and the Scheduler must be signalled


class LockAcquireIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val valid = Input(Bool())
  val tid = Input(UInt(conf.threadBits.W))
  val grant = Output(Bool())

  def driveDefaults(): Unit = {
    grant := false.B
  }

  def driveDefaultsFlipped() = {
    valid := false.B
    tid := 0.U
  }
}

class LockReleaseIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val valid = Input(Bool())
  val tid = Input(UInt(conf.threadBits.W))

  def driveDefaultsFlipped() = {
    valid := false.B
    tid := 0.U
  }
}

class LockThreadReleasedIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val valid = Output(Bool())
  val tid = Output(UInt(conf.threadBits.W))

  def driveDefaults() = {
    valid := false.B
    tid := 0.U
  }
}

class LockIO(implicit val conf: FlexpretConfiguration) extends Bundle {
  val acquire = new LockAcquireIO()
  val release = new LockReleaseIO()
  val threadRelease = new LockThreadReleasedIO()

  def driveDefaultsFlipped() = {
    acquire.driveDefaultsFlipped()
    release.driveDefaultsFlipped()
  }

  def driveDefaults() = {
    acquire.driveDefaults()
    threadRelease.driveDefaults()
  }
}

class Lock(implicit val conf: FlexpretConfiguration) extends Module {
  val io = IO(new LockIO())
  io.driveDefaults()

  // The lock
  val regLocked = RegInit(false.B)
  val regOwner = RegInit(0.U(conf.threadBits.W))

  // FIFO for storing threads waiting for the lock
  val fifo = Module(new Queue(UInt(conf.threadBits.W), conf.threads)).io

  // Handle acquiring of the lock
  when(io.acquire.valid) {
    when(regLocked) {
      io.acquire.grant := false.B
      fifo.enq.valid := true.B
      fifo.enq.bits := io.acquire.tid
      assert(fifo.enq.fire)
    }.otherwise{
      io.acquire.grant := true.B
      regLocked := true.B
      regOwner := io.acquire.tid
    }
  }

  // Handle releasing the lock
  when(io.release.valid) {
    assert(io.release.tid === regOwner)
    assert(regLocked)

    when (fifo.count === 0.U) {
      // Handle scenario where nobody is waiting
      regLocked := false.B
      regOwner := 0.U // FIXME: Not really necessary
    }.otherwise {
      // Handle scenario where we have waiting threads
      // Release the first one
      fifo.deq.ready := true.B
      regOwner := fifo.deq.bits
      io.threadRelease.valid := true.B
      io.threadRelease.tid := fifo.deq.bits
    }
  }
}
