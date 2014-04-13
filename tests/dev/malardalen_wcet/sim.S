# "Bootloader" for C++ simulator. 
# TODO x26, 27 unaffected?

#include "macros.h"
.text
# Run single thread.
        START_SINGLE_THREAD(x2)
# Set start (x26) and end (x27) scheduling frequencies.
        READ_FLEX_THREADS(x26)
        READ_MAX_THREADS(x27)
        bne x0, x26, set_schedule
        move x26, x27
# Set schedule (also entry point of loop).
set_schedule:
        SET_SCHEDULING_FREQ(x26, x2, x3)
# Reset counters.
        RESET_COUNTERS
# Run C program (return value in x2).
        jal program
# Output results.
        READ_INST_COUNT(x3)
        READ_CYCLE_COUNT(x4)
        addi x4, x4, -1
        TOHOST_SCHEDULING_FREQ(x26, x5)
        TOHOST_INST_COUNT(x3, x5)
        TOHOST_CYCLE_COUNT(x4, x5)
#        bne x0, x2, fail
# Next schedule (if any left to run).
        addi x26, x26, 1
        bge x27, x26, set_schedule
# Indicate pass.
        li x2, 1
        mtpcr x2, PCR_TOHOST
fail:   beq x0, x0, fail
