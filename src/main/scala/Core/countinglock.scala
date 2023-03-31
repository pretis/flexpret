package flexpret.core
import chisel3._
import chisel3.util._

// A simple implementation of a single counting lock. 

class CountingLockIO(implicit val conf: FlexpretConfiguration) extends Bundle {
    // input for increment operation
    val increment = Input(UInt(32.W))

    // input for reset operation
    val reset = Input(Bool())

    // inputs for lock_until operation
    val lock_wait = Input(Bool())
    val tid = Input(UInt(conf.threadBits.W))
    val lock_until = Input(UInt(32.W))

    // outputs: sleep if the current thread should sleep,
    //          wake for whether any thread should wake
    val sleep = Output(Bool())
    val wake = Output(Vec(conf.threads, Bool()))


    def driveInputDefaults() = {
        increment := 0.U
        reset := false.B
        tid := 0.U
        lock_wait := false.B
        lock_until := 0.U
    }
}

class CountingLock(implicit val conf: FlexpretConfiguration) extends Module {
    val io = IO(new CountingLockIO())
    
    val regValue = RegInit(0.U(32.W))
    val regUntil = RegInit(VecInit(Seq.fill(conf.threads) { false.B }))

    when(io.reset) {
        regValue := 0.U
    } .otherwise {
        regValue := regValue + io.increment
    }

    when (io.lock_wait) {
        regUntil(io.tid) := io.lock_until
    }

    io.sleep := io.lock_wait && io.lock_until > regValue 
    for (tid <- 0 until conf.threads) {
        io.wake(tid) := regUntil(tid) <= regValue
    }
}