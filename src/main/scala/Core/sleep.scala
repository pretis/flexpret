package flexpret.core

import chisel3._
import chisel3.util._



class SleeperIO(implicit val conf: FlexpretConfiguration) extends Bundle {
    val valid = Input(Bool())
    val wake = Input(Bool())
    val tid = Input(UInt(conf.threadBits.W))
    val state = Output(UInt(2.W))
}


class Sleeper(implicit val conf: FlexpretConfiguration) extends Module {
    val io = IO(new SleeperIO())
    io.state := 3.U // invalid state

    val regAwake = RegInit(0.U(conf.threads.W))
    val regCaffeinated = RegInit(0.U(conf.threads.W))

    val mask = 1.U(conf.threads.W) << io.tid
    val awake = (regAwake & mask) =/= 0.U(conf.threads.W)
    val caffeinated = (regCaffeinated & mask) =/= 0.U(conf.threads.W)

    when(io.valid) {
        when(io.wake) {
            when (awake || caffeinated) { // set state to caffeinated
                regAwake := regAwake & (~mask)
                regCaffeinated := regCaffeinated | mask
                io.state := 2.U
            } .otherwise { // set state to awake
                regAwake := regAwake | mask
                regCaffeinated := regCaffeinated & (~mask)
                io.state := 1.U
            }
        }.otherwise {
            when (caffeinated) { // set state to awake
                regAwake := regAwake | mask
                regCaffeinated := regCaffeinated & (~mask)
                io.state := 1.U
            } .otherwise { // set state to asleep
                regAwake := regAwake & (~mask)
                regCaffeinated := regCaffeinated & (~mask)
                io.state := 0.U
            }
        }
    }
}