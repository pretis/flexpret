# Michael Zimmer (mzimmer@eecs.berkeley.edu)


PROG = complex-mc
MAX_CYCLES = 20000000

SCHEDULE=0x53425140
TMODES=0x0000A000

T0 = t0.o t0_taskA1.o
T1 = t1.o t1_taskA2.o
T2 = t2.o t2_taskA3.o
T3 = t3.o t3_taskA4.o
T4 = t4.o t4_taskB1.o t4_taskB2.o t4_taskB3.o
T5 = t5.o t5_taskB4.o t5_taskB5.o t5_taskB6.o t5_taskB7.o
T6 = t6.o t6_taskC1.o t6_taskD1.o t6_taskD2.o t6_taskD3.o t6_taskD4.o
T7 = t7.o t7_taskD5.o t7_taskD6.o t7_taskD7.o t7_taskD8.o t7_taskD9.o
OBJECT_FILES = $(T0) $(T1) $(T2) $(T3) $(T4) $(T5) $(T6) $(T7)

$(PROG_BUILD_DIR):
	mkdir -p $@

$(PROG_BUILD_DIR)/%.o: %.S | $(PROG_BUILD_DIR)
	$(RISCV_GCC) -I$(TESTS_DIR)/include -DSCHEDULE=$(SCHEDULE) -DTMODES=$(TMODES) -c $< -o $@

$(PROG_BUILD_DIR)/%.o : %.c | $(PROG_BUILD_DIR)
	$(RISCV_GCC) -Wall -O2 -fno-common -I$(TESTS_DIR)/include -D$(PROG_CONFIG) -c $^ -o $@
	$(RISCV_OBJCOPY) --prefix-symbols=$(@:$(PROG_BUILD_DIR)/%.o=%)_ $@

$(PROG:%=$(PROG_BUILD_DIR)/%.bin): $(PROG_SRC_DIR)/layout-8t.ld $(addprefix $(PROG_BUILD_DIR)/, init.o $(OBJECT_FILES)) 
	$(RISCV_GCC) -nostdlib -I$(TESTS_DIR)/include -T $^ -o $@
	$(RISCV_OBJDUMP) $@ > $(@:.bin=.dump)
