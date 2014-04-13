/******************************************************************************
cpath.scala:
  Control unit.
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

import Instructions._
import CoreConstants._

class CtlToDatIo(conf: CoreConfig) extends Bundle() 
{
  val exe_pc_sel  = UInt(OUTPUT, 2)
  val br_type     = UInt(OUTPUT, 4)
  val if_kill     = Bool(OUTPUT) 
  val dec_kill    = Bool(OUTPUT) 
  val dec_stall   = Bool(OUTPUT)
  val op2_sel     = UInt(OUTPUT, 3)
  val alu_fun     = UInt(OUTPUT, 4)
  val wb_sel      = UInt(OUTPUT, 3)
  val wa_sel      = Bool(OUTPUT) 
  val rf_wen      = Bool(OUTPUT) 
  val mem_r       = Bool(OUTPUT)
  val mem_w       = Bool(OUTPUT) 
  val mem_mask    = UInt(OUTPUT, 3)
  val pcr_fcn     = UInt(OUTPUT, 2)
  val next_pc_sel = Vec.fill(conf.threads) { UInt(OUTPUT, 3) }
  val next_tid    = UInt(OUTPUT, conf.threadBits)
  val next_valid  = Bool(OUTPUT)
  val next_epc    = Vec.fill(conf.threads) { UInt(OUTPUT, 2) } //ifex
  val ie_enable   = Bool(OUTPUT)  //ifie
  val ie_disable  = Bool(OUTPUT) //ifie
  val du_enable   = Bool(OUTPUT)  //ifdu
  val tsleep = Bool(OUTPUT)
}

class ControlIo(conf: CoreConfig) extends Bundle() 
{
  val dat  = new DatToCtlIo(conf).flip()
  val ctl  = new CtlToDatIo(conf)
}


class Control(conf: CoreConfig) extends Module 
{
  val io = new ControlIo(conf)

  val default = List(N, BR_N  , OP2_X    , OEN_0, OEN_0, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N)
  val csignals = 
     ListLookup(io.dat.dec_inst, default,
              Array(       /* val  |  BR  |   op2    |  R1  |  R2  |  ALU      |  wb   | wa   | rf   | mem  | mem  | mem   | pcr  */
                           /* inst | type |    sel   |  oen |  oen |   fcn     |  sel  | sel  | wen  |  en  |  wr  | mask  |      */
                 LB      -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_MEM, WA_RD, REN_1, MEN_1, MWR_0, MSK_B , PCR_N),
                 LH      -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_MEM, WA_RD, REN_1, MEN_1, MWR_0, MSK_H , PCR_N),
                 LW      -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_MEM, WA_RD, REN_1, MEN_1, MWR_0, MSK_W , PCR_N),
                 LBU     -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_MEM, WA_RD, REN_1, MEN_1, MWR_0, MSK_BU, PCR_N),
                 LHU     -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_MEM, WA_RD, REN_1, MEN_1, MWR_0, MSK_HU, PCR_N),
                 SB      -> List(Y, BR_N  , OP2_BTYPE, OEN_1, OEN_1, ALU_ADD   , WB_X  , WA_X , REN_0, MEN_1, MWR_1, MSK_B , PCR_N),
                 SH      -> List(Y, BR_N  , OP2_BTYPE, OEN_1, OEN_1, ALU_ADD   , WB_X  , WA_X , REN_0, MEN_1, MWR_1, MSK_H , PCR_N),
                 SW      -> List(Y, BR_N  , OP2_BTYPE, OEN_1, OEN_1, ALU_ADD   , WB_X  , WA_X , REN_0, MEN_1, MWR_1, MSK_W , PCR_N),
                 // TODO: AMO
                 
                 LUI     -> List(Y, BR_N  , OP2_LTYPE, OEN_0, OEN_0,ALU_COPY_2 , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 
                 ADDI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 ANDI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_AND   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 ORI     -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_OR    , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 XORI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_XOR   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SLTI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_SLT   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SLTIU   -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_SLTU  , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SLLI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_SLL   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SRAI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_SRA   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SRLI    -> List(Y, BR_N  , OP2_ITYPE, OEN_1, OEN_0, ALU_SRL   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 
                 SLL     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SLL   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 ADD     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_ADD   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SUB     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SUB   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SLT     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SLT   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SLTU    -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SLTU  , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 riscvAND-> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_AND   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 riscvOR -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_OR    , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 riscvXOR-> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_XOR   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SRA     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SRA   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 SRL     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_SRL   , WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 MUL     -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_MUL   , WB_MUL, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 MULH    -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_MULH  , WB_MUL, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 MULHSU  -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_MULHSU, WB_MUL, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 MULHU   -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_MULHU , WB_MUL, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 // TODO: div
                 
                 J       -> List(Y, BR_J  , OP2_JTYPE, OEN_0, OEN_0, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 JAL     -> List(Y, BR_J  , OP2_JTYPE, OEN_0, OEN_0, ALU_X     , WB_PC4, WA_RA, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 JALR_C  -> List(Y, BR_JR , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_PC4, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 JALR_R  -> List(Y, BR_JR , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_PC4, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 JALR_J  -> List(Y, BR_JR , OP2_ITYPE, OEN_1, OEN_0, ALU_ADD   , WB_PC4, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 RDNPC   -> List(Y, BR_N  , OP2_X    , OEN_0, OEN_0, ALU_X     , WB_PC4, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_N),
                 BEQ     -> List(Y, BR_EQ , OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 BNE     -> List(Y, BR_NE , OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 BGE     -> List(Y, BR_GE , OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 BGEU    -> List(Y, BR_GEU, OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 BLT     -> List(Y, BR_LT , OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 BLTU    -> List(Y, BR_LTU, OP2_BTYPE, OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_N),
                 MTPCR   -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_COPY_2, WB_ALU, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_T),
                 MFPCR   -> List(Y, BR_N  , OP2_X    , OEN_1, OEN_1, ALU_X     , WB_PCR, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_F),
//ifdu ifgt ifee
// TODO: change to concat arrays?
                 GT_L    -> (if(conf.getTime) { 
                            List(Y, BR_N  , OP2_RS2  , OEN_0, OEN_0, ALU_X     , WB_GTL, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_F)
                            } else { default }),
                 GT_H    -> (if(conf.getTime) {
                            List(Y, BR_N  , OP2_RS2  , OEN_0, OEN_0, ALU_X     , WB_GTH, WA_RD, REN_1, MEN_0, MWR_X, MSK_X , PCR_F)
                            } else { default }),
                 //DU      -> (if(conf.delayUntil) {
                 //           List(Y, BR_DU , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F)
                 //           } else { default }),
                 DU      -> (if(conf.delayUntil) {
                            List(Y, BR_N , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F)
                            } else { default }),
                 IE_E    -> (if(conf.exceptionOnExpire) {
                            List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F)
                            } else { default }),
                 IE_D    -> (if(conf.exceptionOnExpire) {
                            List(Y, BR_N  , OP2_X    , OEN_0, OEN_0, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F)
                            } else { default })
                 //DMA_CH  -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F),
                 //DMA_LD  -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F),
                 //DMA_ST  -> List(Y, BR_N  , OP2_RS2  , OEN_1, OEN_1, ALU_X     , WB_X  , WA_X , REN_0, MEN_0, MWR_X, MSK_X , PCR_F)
                 ));

  // Put these control signals in variables
  val cs_val_inst :: cs_br_type :: cs_op2_sel :: cs_rs1_oen :: cs_rs2_oen :: cs_alu_fun :: cs_wb_sel :: cs_wa_sel :: cs_rf_wen :: cs_mem_en :: cs_mem_rw :: cs_mem_mask :: cs_pcr_fcn :: Nil = csignals;

  val ifkill = Bool() // Kill instruction in fetch stage (NOP to decode)
  val deckill = Bool() // Kill instruction in decode stage (NOP to execute)
  val decstall = Bool() // Repeat decode (refetch w/o PC+4 and NOP to execute)
  val replaydec = Bool() // Replay current instruction in decode next time thread fetches.

  replaydec := Bool(false)
  // Notes: To implement, need to use storage register and provide it to exe, mem, and wb to allow forwarding to work.
  
  // Branch Logic (Predict NOT taken)
  val ctrl_exe_pc_sel
     = Lookup(io.dat.exe_br_type, UInt(0, 4), 
           Array(   BR_N  -> PC_PLUS4, 
                    BR_NE -> Mux(!io.dat.exe_br_eq,  PC_BRJMP, PC_PLUS4),
                    BR_EQ -> Mux( io.dat.exe_br_eq,  PC_BRJMP, PC_PLUS4),
                    BR_GE -> Mux(!io.dat.exe_br_lt,  PC_BRJMP, PC_PLUS4),
                    BR_GEU-> Mux(!io.dat.exe_br_ltu, PC_BRJMP, PC_PLUS4),
                    BR_LT -> Mux( io.dat.exe_br_lt,  PC_BRJMP, PC_PLUS4),
                    BR_LTU-> Mux( io.dat.exe_br_ltu, PC_BRJMP, PC_PLUS4),
                    BR_J  -> PC_BRJMP,
                    BR_JR -> PC_JALR//,
                    //BR_DU -> (if(conf.delayUntil) { Mux( io.dat.exe_du_wait, PC_DU, PC_PLUS4) } else { PC_PLUS4 }) //ifdu
                    ));

  // Thread Scheduling (next thread ID to fetch).
  val scheduler = Module(new Scheduler(conf))
  scheduler.io.slots := (0 until 8).map(i => io.dat.exe_schedule(4*i+3,4*i).toUInt)
  scheduler.io.threadModes := io.dat.exe_thread_modes
  val next_tid = scheduler.io.thread
  val next_valid = Bool()
  next_valid := scheduler.io.valid 
  
  // Select source for next PC of each thread.
  val next_pc_sel = Vec.fill(conf.threads) { UInt() }
  val starting = Reg(init = Bool(true))
  starting := Bool(false) 

  for(tid <- 0 until conf.threads) {
    next_pc_sel(tid) := NPC_PCREG
    // Use PC reg when processor comes out of reset.
    when(starting) {
      next_pc_sel(tid) := NPC_PCREG
    // If exception occurred.
    } .elsewhen(io.dat.exe_exception(tid)) { //ifex
      next_pc_sel(tid) := NPC_EVEC
    // If branch/jump target address is available from execute stage, use it.
    // (Forward to prevent waiting another cycle for storage in PC reg)
    } .elsewhen(io.dat.exe_tid === UInt(tid) && ctrl_exe_pc_sel != PC_PLUS4) {
      next_pc_sel(tid) := NPC_BRJMP
    // Replay instruction in decode next time thread is fetched.
    } .elsewhen(replaydec) {
      next_pc_sel(tid) := NPC_DEC
    // If next PC is available from fetch stage, use it.
    // (Forward to prevent waiting another cycle for storage in PC reg)
    } .elsewhen(io.dat.if_tid === UInt(tid) && !decstall && !ifkill && io.dat.if_valid) {
      next_pc_sel(tid) := NPC_PLUS4
    }
  }


  if(conf.flex || conf.threads < 3)
  {
    val dec_tid = io.dat.dec_tid
    val dec_rs1_addr = io.dat.dec_inst(26, 22).toUInt
    val dec_rs2_addr = io.dat.dec_inst(21, 17).toUInt
    val dec_wbaddr  = Mux(cs_wa_sel.toBool, io.dat.dec_inst(31, 27).toUInt, RA)


    // Keep track of instruction in execute stage to detect load/use.
    //TODO reset states
    val exe_inst_load_use = Bool()
    exe_inst_load_use := Bool(false)
    //val mem_inst_load_use = Bool()
    //mem_inst_load_use := Bool(false)

    val exe_reg_tid         = Reg(next = dec_tid) //dp?
    val exe_reg_wbaddr      = Reg(next = Mux(deckill || decstall, UInt(0), dec_wbaddr)) //dp?
    val exe_inst_mem   = Reg(next = Mux(deckill || decstall, Bool(false), (cs_wb_sel === WB_MEM))) //dp?
    val exe_inst_mul = Reg(next = Mux(deckill || decstall, Bool(false), (cs_wb_sel === WB_MUL))) //dp?
    
    //val mem_reg_tid = Reg(next = exe_reg_tid)
    //val mem_reg_wbaddr = Reg(next = exe_reg_wbaddr)
    //val mem_inst_mul = Reg(next = exe_inst_mul)

    // Possible load-use cases depend on configuration.
    if(conf.mulStages >=2) {
      exe_inst_load_use := exe_inst_mem || exe_inst_mul
    } else {
      exe_inst_load_use := exe_inst_mem
    }
    //if(conf.mulStages == 3) {
    //  mem_inst_load_use := mem_inst_mul
    //}

    // Check for match between thread ID of different stages. 
    val if_ex_tid = (io.dat.if_tid === exe_reg_tid)
    val dec_ex_tid = (io.dat.dec_tid === exe_reg_tid)
    
    // If branch/jump taken or decode instruction is being replayed, must kill fetch and decode stages if they belong
    // to the same thread (Bubbles are inserted).
    ifkill  := if_ex_tid && (ctrl_exe_pc_sel != PC_PLUS4 || replaydec)
    deckill := dec_ex_tid && (ctrl_exe_pc_sel != PC_PLUS4 || replaydec)

    // Stall decode for load-use hazard (only occurs with 1 active thread).
    // TODO why tobool
    val rs1_exe_dep = cs_rs1_oen.toBool && (dec_rs1_addr === exe_reg_wbaddr)
    val rs2_exe_dep = cs_rs2_oen.toBool && (dec_rs2_addr === exe_reg_wbaddr) 
    val wb_exe_dep = exe_reg_wbaddr != UInt(0, 5)
    decstall := dec_ex_tid && (rs1_exe_dep || rs2_exe_dep) && wb_exe_dep && exe_inst_load_use //TODO: what about during schedule change?

    // Replay decode for load-use hazard for 2+ cycle spacing.
    //if(conf.mulStages >= 3) {
    //  val tid_mem_dep = (io.dat.dec_tid === mem_reg_tid)
    //  val rs1_mem_dep = cs_rs1_oen.toBool && (dec_rs1_addr === mem_reg_wbaddr)
    //  val rs2_mem_dep = cs_rs2_oen.toBool && (dec_rs2_addr === mem_reg_wbaddr) 
    //  val wb_mem_dep = mem_reg_wbaddr != UInt(0, 5)
    //  replaydec := tid_mem_dep && (rs1_mem_dep || rs2_mem_dep) && wb_mem_dep && mem_inst_load_use
    //}

  } else {
    ifkill := Bool(false)
    deckill := Bool(false)
    decstall := Bool(false)
  }
  
  val tsleep = Bool()
  tsleep := Bool(false)
  when(io.dat.dec_inst === TS && io.dat.exe_ie_en(io.dat.dec_tid) === Bool(true)) {
    tsleep := Bool(true) //todo if flex?
  }
  when(tsleep && (io.dat.if_tid === io.dat.dec_tid)) {
    ifkill := Bool(true)
  }
  when(tsleep && (next_tid === io.dat.dec_tid)) {
    next_valid := Bool(false)
  }

  // Exceptions
  if(conf.exceptions) {
    for(tid <- 0 until conf.threads) {
      when(io.dat.exe_exception(tid)) {
        // Need to interrupt thread. Kill instructions of same thread in fetch 
        // and decode stages (instructions in other stage will complete) and 
        // store back PC of decode instruction.
        when(io.dat.if_tid === Bits(tid, conf.threadBits)) {
          ifkill := Bool(true)
        }
        when(io.dat.dec_tid === Bits(tid, conf.threadBits)) {
          deckill := Bool(true)
        }
      }
    }
  }



  // Keep track of next uncommitted instruction for each thread.
  val next_epc = Vec.fill(conf.threads) { UInt() }
  for(tid <- 0 until conf.threads) {
    next_epc(tid) := EPC_PCREG
    if(conf.exceptions) {
      when(io.dat.exe_tid === UInt(tid) && ctrl_exe_pc_sel != PC_PLUS4) {
        next_epc(tid) := EPC_BRJMP
      } .elsewhen(io.dat.dec_tid === UInt(tid) && io.dat.dec_valid) {
        next_epc(tid) := EPC_DECPC
      } .elsewhen(io.dat.if_tid === UInt(tid) && io.dat.if_valid) {
        next_epc(tid) := EPC_IFPC
      }
    }
  }  

  // Test code for replay.
  //val temp = Reg(init = Bool(false))
  //when(io.dat.dec_inst === MTPCR) {
  //  //1 thread.
  //  when(io.dat.if_tid === io.dat.dec_tid && !temp) {
  //    decstall := Bool(true)
  //    temp := Bool(true) 
  //  //2+ threads.
  //  } .elsewhen(!temp) {
  //    replaydec := Bool(true)
  //    temp := Bool(true)
  //  } .elsewhen(temp) {
  //    temp := Bool(false)
  //  }
  //}
  val ie_e = Bool()
  ie_e := Bool(false)
  val ie_d = Bool()
  ie_d := Bool(false)

  // Done this way so generated verilog code contains a casez.
  if(conf.exceptionOnExpire) {
    val ie = Lookup(io.dat.dec_inst, UInt(0,2), Array(
                        IE_E -> UInt(1, 2),
                        IE_D -> UInt(2, 2)))
    when(ie === UInt(1, 2) && !deckill && !decstall) {
      ie_e := Bool(true)
    }
    when(ie === UInt(2, 2) && !deckill && !decstall) {
      ie_d := Bool(true)
    }
  }

  val du_e = Bool()
  du_e := Bool(false)
  val du_d = Bool()
  du_d := Bool(false)
  if(conf.delayUntil) {
    val du = Lookup(io.dat.dec_inst, UInt(0,1), Array(
                        DU -> UInt(1, 1)))
    when(du === UInt(1, 1) && !deckill && !decstall) {
      tsleep := Bool(true)
      du_e := Bool(true)
    }
  }

  // TODO: must cause thread to stall!
  io.ctl.tsleep := tsleep
  
  
  io.ctl.exe_pc_sel := ctrl_exe_pc_sel
  io.ctl.br_type    := cs_br_type
  io.ctl.if_kill    := ifkill
  io.ctl.dec_kill   := deckill
  io.ctl.dec_stall  := decstall
  io.ctl.op2_sel    := cs_op2_sel
  io.ctl.alu_fun    := cs_alu_fun
  io.ctl.wb_sel     := cs_wb_sel
  io.ctl.wa_sel     := cs_wa_sel.toBool
  io.ctl.rf_wen     := cs_rf_wen.toBool
  io.ctl.pcr_fcn    := cs_pcr_fcn
  io.ctl.mem_r      := cs_mem_en.toBool && !cs_mem_rw.toBool
  io.ctl.mem_w      := cs_mem_en.toBool && cs_mem_rw.toBool
  io.ctl.mem_mask   := cs_mem_mask
  io.ctl.next_pc_sel:= next_pc_sel
  io.ctl.next_tid   := next_tid 
  io.ctl.next_valid := next_valid
  io.ctl.next_epc   := next_epc
  io.ctl.ie_enable  := ie_e
  io.ctl.ie_disable := ie_d
  io.ctl.du_enable  := du_e

}

}
