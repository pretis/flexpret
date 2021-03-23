# Michael Zimmer (mzimmer@eecs.berkeley.edu)

# TODO: could also save symbol in .data section to reduce redundancy of code

#include "macros.h"
.text

# Hacky..
# Go to correct thread startup code.
mfpcr x2, PCR_TID
beq x2, x0, init
addi x2, x2, -1
beq x2, x0, t1_startup
addi x2, x2, -1
beq x2, x0, t2_startup
addi x2, x2, -1
beq x2, x0, t3_startup

# Thread 0 will initialize the processor before starting.
init:

# Set memory isolation.
# Assumes 1kB pages.
MEM_ISO(0, t0_sdata, t0_edata, x2, x3)
MEM_ISO(1, t1_sdata, t1_edata, x2, x3)
MEM_ISO(2, t2_sdata, t2_edata, x2, x3)
MEM_ISO(3, t3_sdata, t3_edata, x2, x3)
# No shared memory.
mtpcr x0, PCR_SHARED

# Set thread scheduling.
li x2, SCHEDULE
li x3, TMODES
#li x2, ( (SCH_D << 28) ^ (SCH_D << 24) ^ (SCH_D << 20) ^ (SCH_D << 16) ^ \
#         (3 << 12) ^ (2 << 8) ^ (1 << 4) ^ (0 << 0) )
#li x3, ( (TMODE_HA << 6) ^ (TMODE_HA << 4) ^ (TMODE_HA << 2) ^ (TMODE_HA << 0) )
mtpcr x2, PCR_SCHEDULE
mtpcr x3, PCR_TMODES

t0_startup:
STARTUP(t0_main, t0_sbss, t0_ebss, t0_edata, x2, x3)
t1_startup:
STARTUP(t1_main, t1_sbss, t1_ebss, t1_edata, x2, x3)
t2_startup:
STARTUP(t2_main, t2_sbss, t2_ebss, t2_edata, x2, x3)
t3_startup:
STARTUP(t3_main, t3_sbss, t3_ebss, t3_edata, x2, x3)

