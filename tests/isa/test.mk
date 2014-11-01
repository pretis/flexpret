# Compile assembly test suite and generate additional files.
# Tests adapted from https://github.com/ucb-bar/riscv-tests
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

PROG = $(PROG_BASE) $(PROG_DEP)

PROG_BASE= \
	add addi \
	and andi \
	auipc \
	beq bge bgeu blt bltu bne \
	fence_i \
	j jal jalr \
	lb lbu lh lhu lw \
	lui \
	or ori \
	sb sh sw \
	sll slli \
	slt slti \
	sra srai \
	srl srli \
	sub \
	xor xori \

PROG_DEP= \
	s_csr

#I?: 
#sltiu sltu fence scall sbreak rdcycle rdcycleh rdtime rdtimeh rdinstret rdinstreth
#M: 
#mul mulh mulhu mulhsu \
#div divu \
#rem remu \
#A: 
#amoadd_w amoand_w amomax_w amomaxu_w amomin_w amominu_w amoor_w amoswap_w \
#A?:
#amoxor_w lr_w sc_w

#ifeq ($(GET_TIME),true)
#  ifeq ($(DELAY_UNTIL),true)
##	PROG_DEP += riscv_gtdu
#  endif
#  ifeq ($(EXCEPTION_ON_EXPIRE),true)
##	PROG_DEP += riscv_ie
#  endif
#endif

$(DEFAULT_RULES)

#rv32ui_mc_tests = \
#	lrsc
#
#rv32ui_p_tests = $(addprefix rv32ui-p-, $(rv32ui_sc_tests))
#rv32ui_pm_tests = $(addprefix rv32ui-pm-, $(rv32ui_mc_tests))
#
#spike_tests += $(rv32ui_p_tests) $(rv32ui_pm_tests)
