# Compile assembly test suite and generate additional files.
# Tests adapted from https://github.com/ucb-bar/riscv-tests
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)


PROG= \
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
	$(if $(findstring true, $(MUL)), mul mulh mulhu mulhsu) \
	$(if $(findstring ex, $(SUFFIX)), $(PROG_EX)) \
	$(if $(findstring ti, $(SUFFIX)), $(PROG_TI)) \
	$(if $(findstring all, $(SUFFIX)), $(PROG_ALL)) \

PROG_EX= \
	exc_illegal \
	exc_external
PROG_TI= \
	$(PROG_EX) \
	flex_du \
	flex_wu \
	flex_ie \
	flex_ee
PROG_ALL= \
	$(PROG_TI) \

	
#s_csr \
#exc_priv \
#flex_gpio

MAX_CYCLES = 150000
EMULATOR_OPTS ?= --sweep

$(DEFAULT_RULES)
