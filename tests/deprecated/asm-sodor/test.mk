# Compile assembly test suite and generate additional files.
# Tests from Sodor educational RISC-V processors project. 
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)


PROG = $(PROG_BASE) $(PROG_DEP)

PROG_BASE= \
	riscv_example \
	riscv-v1_addi \
	riscv-v1_bne \
	riscv-v1_sw \
	riscv-v2_add \
	riscv-v2_addi \
	riscv-v2_and \
	riscv-v2_andi \
	riscv-v2_beq \
	riscv-v2_bge \
	riscv-v2_bgeu \
	riscv-v2_blt \
	riscv-v2_bltu \
	riscv-v2_bne \
	riscv-v2_j \
	riscv-v2_jal \
	riscv-v2_jalr  \
	riscv-v2_jalr_j \
	riscv-v2_jalr_r \
	riscv-v2_lui \
	riscv-v2_lw \
	riscv-v2_or \
	riscv-v2_ori \
	riscv-v2_sll \
	riscv-v2_slli \
	riscv-v2_slt \
	riscv-v2_slti \
	riscv-v2_sltiu \
	riscv-v2_sltu \
	riscv-v2_sra \
	riscv-v2_srai \
	riscv-v2_srl \
	riscv-v2_srli \
	riscv-v2_sub \
	riscv-v2_sw \
	riscv-v2_xor \
	riscv-v2_xori \
	riscv-v3_lb \
	riscv-v3_lbu \
	riscv-v3_lh \
	riscv-v3_lhu \
	riscv-v3_sb \
	riscv-v3_sh \
	riscv_mul \
	riscv_mulh \
	riscv_mulhsu \
	riscv_mulhu \
    riscv_ispm \
    riscv_tsup \
    riscv_iso \

ifeq ($(GET_TIME),true)
  ifeq ($(DELAY_UNTIL),true)
	PROG_DEP += riscv_gtdu
  endif
  ifeq ($(EXCEPTION_ON_EXPIRE),true)
	PROG_DEP += riscv_ie
  endif
endif

$(DEFAULT_RULES)
