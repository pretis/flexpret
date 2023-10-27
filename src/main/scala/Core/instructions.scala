/******************************************************************************
 * File: instructions.scala
 * Description: Instruction constants
 * datapath.
 * Author: Michael Zimmer (mzimmer@eecs.berkeley.edu)
 * Contributors: Edward Wang (edwardw@eecs.berkeley.edu)
 * License: See LICENSE.txt
 * ******************************************************************************/
package Core

import chisel3._
import chisel3.util._

/* Automatically generated by parse-opcodes */
object Instructions {
  def BEQ                = BitPat("b?????????????????000?????1100011")
  def BNE                = BitPat("b?????????????????001?????1100011")
  def BLT                = BitPat("b?????????????????100?????1100011")
  def BGE                = BitPat("b?????????????????101?????1100011")
  def BLTU               = BitPat("b?????????????????110?????1100011")
  def BGEU               = BitPat("b?????????????????111?????1100011")
  def JALR               = BitPat("b?????????????????000?????1100111")
  def JAL                = BitPat("b?????????????????????????1101111")
  def LUI                = BitPat("b?????????????????????????0110111")
  def AUIPC              = BitPat("b?????????????????????????0010111")
  def ADDI               = BitPat("b?????????????????000?????0010011")
  def SLLI               = BitPat("b000000???????????001?????0010011")
  def SLTI               = BitPat("b?????????????????010?????0010011")
  def SLTIU              = BitPat("b?????????????????011?????0010011")
  def XORI               = BitPat("b?????????????????100?????0010011")
  def SRLI               = BitPat("b000000???????????101?????0010011")
  def SRAI               = BitPat("b010000???????????101?????0010011")
  def ORI                = BitPat("b?????????????????110?????0010011")
  def ANDI               = BitPat("b?????????????????111?????0010011")
  def ADD                = BitPat("b0000000??????????000?????0110011")
  def SUB                = BitPat("b0100000??????????000?????0110011")
  def SLL                = BitPat("b0000000??????????001?????0110011")
  def SLT                = BitPat("b0000000??????????010?????0110011")
  def SLTU               = BitPat("b0000000??????????011?????0110011")
  def XOR                = BitPat("b0000000??????????100?????0110011")
  def SRL                = BitPat("b0000000??????????101?????0110011")
  def SRA                = BitPat("b0100000??????????101?????0110011")
  def OR                 = BitPat("b0000000??????????110?????0110011")
  def AND                = BitPat("b0000000??????????111?????0110011")
  def ADDIW              = BitPat("b?????????????????000?????0011011")
  def SLLIW              = BitPat("b0000000??????????001?????0011011")
  def SRLIW              = BitPat("b0000000??????????101?????0011011")
  def SRAIW              = BitPat("b0100000??????????101?????0011011")
  def ADDW               = BitPat("b0000000??????????000?????0111011")
  def SUBW               = BitPat("b0100000??????????000?????0111011")
  def SLLW               = BitPat("b0000000??????????001?????0111011")
  def SRLW               = BitPat("b0000000??????????101?????0111011")
  def SRAW               = BitPat("b0100000??????????101?????0111011")
  def LB                 = BitPat("b?????????????????000?????0000011")
  def LH                 = BitPat("b?????????????????001?????0000011")
  def LW                 = BitPat("b?????????????????010?????0000011")
  def LD                 = BitPat("b?????????????????011?????0000011")
  def LBU                = BitPat("b?????????????????100?????0000011")
  def LHU                = BitPat("b?????????????????101?????0000011")
  def LWU                = BitPat("b?????????????????110?????0000011")
  def SB                 = BitPat("b?????????????????000?????0100011")
  def SH                 = BitPat("b?????????????????001?????0100011")
  def SW                 = BitPat("b?????????????????010?????0100011")
  def SD                 = BitPat("b?????????????????011?????0100011")
  def FENCE              = BitPat("b?????????????????000?????0001111")
  def FENCE_I            = BitPat("b?????????????????001?????0001111")
  def MUL                = BitPat("b0000001??????????000?????0110011")
  def MULH               = BitPat("b0000001??????????001?????0110011")
  def MULHSU             = BitPat("b0000001??????????010?????0110011")
  def MULHU              = BitPat("b0000001??????????011?????0110011")
  def DIV                = BitPat("b0000001??????????100?????0110011")
  def DIVU               = BitPat("b0000001??????????101?????0110011")
  def REM                = BitPat("b0000001??????????110?????0110011")
  def REMU               = BitPat("b0000001??????????111?????0110011")
  def MULW               = BitPat("b0000001??????????000?????0111011")
  def DIVW               = BitPat("b0000001??????????100?????0111011")
  def DIVUW              = BitPat("b0000001??????????101?????0111011")
  def REMW               = BitPat("b0000001??????????110?????0111011")
  def REMUW              = BitPat("b0000001??????????111?????0111011")
  def AMOADD_W           = BitPat("b00000????????????010?????0101111")
  def AMOXOR_W           = BitPat("b00100????????????010?????0101111")
  def AMOOR_W            = BitPat("b01000????????????010?????0101111")
  def AMOAND_W           = BitPat("b01100????????????010?????0101111")
  def AMOMIN_W           = BitPat("b10000????????????010?????0101111")
  def AMOMAX_W           = BitPat("b10100????????????010?????0101111")
  def AMOMINU_W          = BitPat("b11000????????????010?????0101111")
  def AMOMAXU_W          = BitPat("b11100????????????010?????0101111")
  def AMOSWAP_W          = BitPat("b00001????????????010?????0101111")
  def LR_W               = BitPat("b00010??00000?????010?????0101111")
  def SC_W               = BitPat("b00011????????????010?????0101111")
  def AMOADD_D           = BitPat("b00000????????????011?????0101111")
  def AMOXOR_D           = BitPat("b00100????????????011?????0101111")
  def AMOOR_D            = BitPat("b01000????????????011?????0101111")
  def AMOAND_D           = BitPat("b01100????????????011?????0101111")
  def AMOMIN_D           = BitPat("b10000????????????011?????0101111")
  def AMOMAX_D           = BitPat("b10100????????????011?????0101111")
  def AMOMINU_D          = BitPat("b11000????????????011?????0101111")
  def AMOMAXU_D          = BitPat("b11100????????????011?????0101111")
  def AMOSWAP_D          = BitPat("b00001????????????011?????0101111")
  def LR_D               = BitPat("b00010??00000?????011?????0101111")
  def SC_D               = BitPat("b00011????????????011?????0101111")
  // System calls
  def SCALL              = BitPat("b00000000000000000000000001110011")
  def SBREAK             = BitPat("b00000000000100000000000001110011")
  def MRET               = BitPat("b00110000001000000000000001110011")
  def SRET               = BitPat("b00010000001000000000000001110011")
  def URET               = BitPat("b00000000001000000000000001110011")
  // CSR operations
  def CSRRW              = BitPat("b?????????????????001?????1110011")
  def CSRRS              = BitPat("b?????????????????010?????1110011")
  def CSRRC              = BitPat("b?????????????????011?????1110011")
  def CSRRWI             = BitPat("b?????????????????101?????1110011")
  def CSRRSI             = BitPat("b?????????????????110?????1110011")
  def CSRRCI             = BitPat("b?????????????????111?????1110011")
  def FADD_S             = BitPat("b0000000??????????????????1010011")
  def FSUB_S             = BitPat("b0000100??????????????????1010011")
  def FMUL_S             = BitPat("b0001000??????????????????1010011")
  def FDIV_S             = BitPat("b0001100??????????????????1010011")
  def FSGNJ_S            = BitPat("b0010000??????????000?????1010011")
  def FSGNJN_S           = BitPat("b0010000??????????001?????1010011")
  def FSGNJX_S           = BitPat("b0010000??????????010?????1010011")
  def FMIN_S             = BitPat("b0010100??????????000?????1010011")
  def FMAX_S             = BitPat("b0010100??????????001?????1010011")
  def FSQRT_S            = BitPat("b010110000000?????????????1010011")
  def FADD_D             = BitPat("b0000001??????????????????1010011")
  def FSUB_D             = BitPat("b0000101??????????????????1010011")
  def FMUL_D             = BitPat("b0001001??????????????????1010011")
  def FDIV_D             = BitPat("b0001101??????????????????1010011")
  def FSGNJ_D            = BitPat("b0010001??????????000?????1010011")
  def FSGNJN_D           = BitPat("b0010001??????????001?????1010011")
  def FSGNJX_D           = BitPat("b0010001??????????010?????1010011")
  def FMIN_D             = BitPat("b0010101??????????000?????1010011")
  def FMAX_D             = BitPat("b0010101??????????001?????1010011")
  def FCVT_S_D           = BitPat("b010000000001?????????????1010011")
  def FCVT_D_S           = BitPat("b010000100000?????????????1010011")
  def FSQRT_D            = BitPat("b010110100000?????????????1010011")
  def FLE_S              = BitPat("b1010000??????????000?????1010011")
  def FLT_S              = BitPat("b1010000??????????001?????1010011")
  def FEQ_S              = BitPat("b1010000??????????010?????1010011")
  def FLE_D              = BitPat("b1010001??????????000?????1010011")
  def FLT_D              = BitPat("b1010001??????????001?????1010011")
  def FEQ_D              = BitPat("b1010001??????????010?????1010011")
  def FCVT_W_S           = BitPat("b110000000000?????????????1010011")
  def FCVT_WU_S          = BitPat("b110000000001?????????????1010011")
  def FCVT_L_S           = BitPat("b110000000010?????????????1010011")
  def FCVT_LU_S          = BitPat("b110000000011?????????????1010011")
  def FMV_X_S            = BitPat("b111000000000?????000?????1010011")
  def FCLASS_S           = BitPat("b111000000000?????001?????1010011")
  def FCVT_W_D           = BitPat("b110000100000?????????????1010011")
  def FCVT_WU_D          = BitPat("b110000100001?????????????1010011")
  def FCVT_L_D           = BitPat("b110000100010?????????????1010011")
  def FCVT_LU_D          = BitPat("b110000100011?????????????1010011")
  def FMV_X_D            = BitPat("b111000100000?????000?????1010011")
  def FCLASS_D           = BitPat("b111000100000?????001?????1010011")
  def FCVT_S_W           = BitPat("b110100000000?????????????1010011")
  def FCVT_S_WU          = BitPat("b110100000001?????????????1010011")
  def FCVT_S_L           = BitPat("b110100000010?????????????1010011")
  def FCVT_S_LU          = BitPat("b110100000011?????????????1010011")
  def FMV_S_X            = BitPat("b111100000000?????000?????1010011")
  def FCVT_D_W           = BitPat("b110100100000?????????????1010011")
  def FCVT_D_WU          = BitPat("b110100100001?????????????1010011")
  def FCVT_D_L           = BitPat("b110100100010?????????????1010011")
  def FCVT_D_LU          = BitPat("b110100100011?????????????1010011")
  def FMV_D_X            = BitPat("b111100100000?????000?????1010011")
  def FLW                = BitPat("b?????????????????010?????0000111")
  def FLD                = BitPat("b?????????????????011?????0000111")
  def FSW                = BitPat("b?????????????????010?????0100111")
  def FSD                = BitPat("b?????????????????011?????0100111")
  def FMADD_S            = BitPat("b?????00??????????????????1000011")
  def FMSUB_S            = BitPat("b?????00??????????????????1000111")
  def FNMSUB_S           = BitPat("b?????00??????????????????1001011")
  def FNMADD_S           = BitPat("b?????00??????????????????1001111")
  def FMADD_D            = BitPat("b?????01??????????????????1000011")
  def FMSUB_D            = BitPat("b?????01??????????????????1000111")
  def FNMSUB_D           = BitPat("b?????01??????????????????1001011")
  def FNMADD_D           = BitPat("b?????01??????????????????1001111")
  def CUSTOM0            = BitPat("b?????????????????000?????0001011")
  def CUSTOM0_RS1        = BitPat("b?????????????????010?????0001011")
  def CUSTOM0_RS1_RS2    = BitPat("b?????????????????011?????0001011")
  def CUSTOM0_RD         = BitPat("b?????????????????100?????0001011")
  def CUSTOM0_RD_RS1     = BitPat("b?????????????????110?????0001011")
  def CUSTOM0_RD_RS1_RS2 = BitPat("b?????????????????111?????0001011")
  def CUSTOM1            = BitPat("b?????????????????000?????0101011")
  def CUSTOM1_RS1        = BitPat("b?????????????????010?????0101011")
  def CUSTOM1_RS1_RS2    = BitPat("b?????????????????011?????0101011")
  def CUSTOM1_RD         = BitPat("b?????????????????100?????0101011")
  def CUSTOM1_RD_RS1     = BitPat("b?????????????????110?????0101011")
  def CUSTOM1_RD_RS1_RS2 = BitPat("b?????????????????111?????0101011")
  def CUSTOM2            = BitPat("b?????????????????000?????1011011")
  def CUSTOM2_RS1        = BitPat("b?????????????????010?????1011011")
  def CUSTOM2_RS1_RS2    = BitPat("b?????????????????011?????1011011")
  def CUSTOM2_RD         = BitPat("b?????????????????100?????1011011")
  def CUSTOM2_RD_RS1     = BitPat("b?????????????????110?????1011011")
  def CUSTOM2_RD_RS1_RS2 = BitPat("b?????????????????111?????1011011")
  def CUSTOM3            = BitPat("b?????????????????000?????1111011")
  def CUSTOM3_RS1        = BitPat("b?????????????????010?????1111011")
  def CUSTOM3_RS1_RS2    = BitPat("b?????????????????011?????1111011")
  def CUSTOM3_RD         = BitPat("b?????????????????100?????1111011")
  def CUSTOM3_RD_RS1     = BitPat("b?????????????????110?????1111011")
  def CUSTOM3_RD_RS1_RS2 = BitPat("b?????????????????111?????1111011")
  val DU = CUSTOM0_RD_RS1_RS2
  val WU = CUSTOM1_RD_RS1_RS2
  val IE = CUSTOM2_RD_RS1_RS2
}
object Causes {
  val misaligned_fetch = 0x0
  val fault_fetch = 0x1
  val illegal_instruction = 0x2
  val privileged_instruction = 0x3
  val fp_disabled = 0x4
  val syscall = 0x6
  val breakpoint = 0x7
  val misaligned_load = 0x8
  val misaligned_store = 0x9
  val fault_load = 0xa
  val fault_store = 0xb
  val accelerator_disabled = 0xc
  // custom (5th bit is interrupt)
  val ee = 0xd
  val ie = 0x1d
  val external_int = 0x1e
  val all = {
    val res = collection.mutable.ArrayBuffer[Int]()
    res += misaligned_fetch
    res += fault_fetch
    res += illegal_instruction
    res += privileged_instruction
    res += fp_disabled
    res += syscall
    res += breakpoint
    res += misaligned_load
    res += misaligned_store
    res += fault_load
    res += fault_store
    res += accelerator_disabled
    res.toArray
  }
}
// 0xc__ CSRs are read-only.
object CSRs {
  val fflags    = 0x1
  val frm       = 0x2
  val fcsr      = 0x3
  val stats     = 0xc0
  val sup0      = 0x500
  val sup1      = 0x501
  val badvaddr  = 0x503
  val ptbr      = 0x504
  val asid      = 0x505   // iMemProtection
  val count     = 0x506
  val compare   = 0x507
  val evec      = 0x508
  val cause     = 0x509
  val status    = 0x50a
  val hartid    = 0x50b
  val impl      = 0x50c   // dMemProtection
  val fatc      = 0x50d
  val send_ipi  = 0x50e
  val clear_ipi = 0x50f
  val core_id = 0x510
  val mepc       = 0x511
  val sepc       = 0x512
  val uepc       = 0x513
  val reset = 0x51d
  val fromhost = 0x51f
  val hwlock    = 0x520

  val tohost0   = 0x530
  val tohost1   = 0x531 
  val tohost2   = 0x532 
  val tohost3   = 0x533 
  val tohost4   = 0x534 
  val tohost5   = 0x535 
  val tohost6   = 0x536 
  val tohost7   = 0x537

  val cycle     = 0xc00
  val time      = 0xc01
  val instret   = 0xc02
  val uarch0    = 0xcc0
  val uarch1    = 0xcc1
  val uarch2    = 0xcc2
  val uarch3    = 0xcc3
  val uarch4    = 0xcc4
  val uarch5    = 0xcc5
  val uarch6    = 0xcc6
  val uarch7    = 0xcc7
  val uarch8    = 0xcc8
  val uarch9    = 0xcc9
  val uarch10   = 0xcca
  val uarch11   = 0xccb
  val uarch12   = 0xccc
  val uarch13   = 0xccd
  val uarch14   = 0xcce
  val uarch15   = 0xccf
  // Extra CSRs to account for 32-bit architecture
  val counth    = 0x586   // FIXME: Why is this not read-only?
  val cycleh    = 0xc80
  val timeh     = 0xc81
  val instreth  = 0xc82
  //flexpret
  val clock     = fflags
  val slots     = badvaddr
  val tmodes    = ptbr
  val iMemProtection  = asid
  val dMemProtection  = impl
  val gpoProtection   = fatc
  val gpiBase   = uarch0
  val gpoBase   = uarch4
  val all = {
    val res = collection.mutable.ArrayBuffer[Int]()
    res += fflags
    res += frm
    res += fcsr
    res += stats
    res += sup0
    res += sup1
    res += badvaddr
    res += ptbr
    res += asid
    res += count
    res += compare
    res += evec
    res += cause
    res += status
    res += hartid
    res += impl
    res += fatc
    res += send_ipi
    res += clear_ipi
    res += core_id
    res += mepc
    res += sepc
    res += uepc
    res += reset
    res += fromhost
    res += hwlock
    res += tohost0 
    res += tohost1 
    res += tohost2 
    res += tohost3 
    res += tohost4 
    res += tohost5 
    res += tohost6 
    res += tohost7
    res += cycle
    res += time
    res += instret
    res += uarch0
    res += uarch1
    res += uarch2
    res += uarch3
    res += uarch4
    res += uarch5
    res += uarch6
    res += uarch7
    res += uarch8
    res += uarch9
    res += uarch10
    res += uarch11
    res += uarch12
    res += uarch13
    res += uarch14
    res += uarch15
    // flexpret
    res += slots
    res += tmodes
    res += iMemProtection
    res += dMemProtection
    res += gpoProtection
    res += gpiBase
    res += gpoBase
    res.toArray
  }
  val all32 = {
    val res = collection.mutable.ArrayBuffer(all:_*)
    res += counth
    res += cycleh
    res += timeh
    res += instreth
    res.toArray
  }
}
