package flexpret.core

import chisel3._
import chisel3.util._



class SleeperIO(implicit val conf: FlexpretConfiguration) extends Bundle {
    val wake = Input(Bool())
    val sleep = Input(Bool())
    val tid = Input(UInt(conf.threadBits.W))
    val state = Output(UInt(2.W)) // resulting state of tid
}


class Sleeper(implicit val conf: FlexpretConfiguration) extends Module {
    val io = IO(new SleeperIO())
    io.state := 3.U // invalid state

    val regStates = RegInit(VecInit(Seq.fill(conf.threads) { 1.U(2.W) }))
    val awake = regStates(io.tid)(0);
    val caffeinated = regStates(io.tid)(1);

    when(io.wake) {
        when (awake || caffeinated) { // set state to caffeinated
            regStates(io.tid) := 2.U
            io.state := 2.U
        } .otherwise { // set state to awake
            regStates(io.tid) := 1.U
            io.state := 1.U
        }
    }
    when(io.sleep) {
        when (caffeinated) { // set state to awake
            regStates(io.tid) := 1.U
            io.state := 1.U
        } .otherwise { // set state to asleep
            regStates(io.tid) := 0.U
            io.state := 0.U
        }
    }
}