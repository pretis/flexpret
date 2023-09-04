package flexpret.core
import chisel3._
import chisel3.util._

// A simple implementation of a set of counting locks; one counting lock per thread

class CountingLockIO(implicit val conf: FlexpretConfiguration) extends Bundle {
    // current thread id, used for all 3 operations
    val tid = Input(UInt(conf.threadBits.W))

    // input for increment operation
    val increment = Input(UInt(32.W))

    // input for reset operation
    val reset = Input(Bool())

    // inputs for lock_until operation
    val lock_wait = Input(Bool())
    val lock_id = Input(UInt(conf.threadBits.W))
    val lock_until = Input(UInt(32.W))

    // outputs: sleep if the current thread should sleep,
    //          wake for whether any thread should wake
    val sleep = Output(Bool())
    val wake = Output(Vec(conf.threads, Bool()))


    def driveInputDefaults() = {
        tid := 0.U
        increment := 0.U
        reset := false.B
        lock_wait := false.B
        lock_id := 0.U
        lock_until := 0.U
    }
}

class CountingLock(implicit val conf: FlexpretConfiguration) extends Module {
    val io = IO(new CountingLockIO())
    
    // value of counting lock owned by each thread
    val regValue = RegInit(VecInit(Seq.fill(conf.threads) { 0.U(32.W) }))

    // what value each thread is waiting for
    val regUntil = RegInit(VecInit(Seq.fill(conf.threads) { 0.U(32.W) }))

    // which counting lock each thread is waiting on. own id means not waiting on anything 
    val regWaitingOn = RegInit(VecInit( Seq.tabulate(conf.threads)(n => n.U(conf.threadBits.W)) ))

    when(io.reset) {
        regValue(io.tid) := 0.U
    } .otherwise {
        regValue(io.tid) := regValue(io.tid) + io.increment
    }

    when (io.lock_wait) {
        regUntil(io.tid) := io.lock_until
        regWaitingOn(io.tid) := io.lock_id
    }

    io.sleep := io.lock_wait && io.lock_until > regValue(io.tid) 
    for (tid <- 0 until conf.threads) {
        when ((tid.U =/= io.tid) && regWaitingOn(tid) === io.tid && regUntil(tid) <= regValue(io.tid)) {
            io.wake(tid) := true.B
            regWaitingOn(tid) := tid.U // set to not waiting on anything
        } .otherwise {
            io.wake(tid) := false.B
        }
    }
}