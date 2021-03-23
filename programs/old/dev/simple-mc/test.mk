# Michael Zimmer (mzimmer@eecs.berkeley.edu)

PROG = simple-mc
PROG_CONFIG = emulator_normal
MAX_CYCLES = 20000000

# TODO depends on core config
# Flex
SCHEDULE?=0xFFEE0210
TMODES?=0x000000A0

# 4R-RR
#SCHEDULE?=0xFFFF3210
#TMODES?=0x00000000

# 4T-VAR
#SCHEDULE?=0xFFFFFFFE
#TMODES?=0x000000AA

$(PROG_BUILD_DIR):
	mkdir -p $@

$(PROG_BUILD_DIR)/%.o: %.S | $(PROG_BUILD_DIR)
	$(RISCV_GCC) -I$(TESTS_DIR)/include -DSCHEDULE=$(SCHEDULE) -DTMODES=$(TMODES) -c $< -o $@

$(PROG_BUILD_DIR)/%.o : %.c | $(PROG_BUILD_DIR)
	$(RISCV_GCC) -Wall -O2 -fno-common -I$(TESTS_DIR)/include -D$(PROG_CONFIG) -c $^ -o $@
	$(RISCV_OBJCOPY) --prefix-symbols=$(@:$(PROG_BUILD_DIR)/%.o=%)_ $@

$(PROG:%=$(PROG_BUILD_DIR)/%.bin): $(PROG_SRC_DIR)/layout-4t.ld $(addprefix $(PROG_BUILD_DIR)/, init.o t0.o t1.o t2.o t3.o t0_taskA.o t1_taskB.o t2_taskC.o t3_taskD.o)
	$(RISCV_GCC) -nostdlib -I$(TESTS_DIR)/include -T $^ -o $@
	$(RISCV_OBJDUMP) $@ > $(@:.bin=.dump)



