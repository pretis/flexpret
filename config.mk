# Default configuration of core, programs, and target.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

# Default FlexPRET core configuration.
# THREADS=[1-8]: Specify number of hardware threads
# FLEXPRET=[true/false]: Use flexible thread scheduling
# ISPM_KBYTES=[]: Size of instruction scratchpad memory (32 bit words)
# DSPM_KBYTES=[]: Size of instruction scratchpad memory (32 bit words)
# MUL=[true/false]: multiplier
# SUFFIX=[min,ex,ti,all]:
# 	min: base RV32I
# 	ex: min+exceptions (necessary)
# 	ti: ex+timing instructions
# 	all: ti+ all exception causes and stats

THREADS ?= 4
FLEXPRET ?= true
ISPM_KBYTES ?= 16
DSPM_KBYTES ?= 16
MUL ?= false
SUFFIX ?= ti

# Target
# TARGET=[emulator/fpga]: Select target
# DEBUG=[true/false]: Generate waveform dump.
TARGET ?= emulator
DEBUG ?= true

# Default program compilation
# PROG_DIR=[path]: Directory of programs in tests/ to compile and/or run
# PROG_CONFIG=[]: Program configuration, start with target name
PROG_DIR ?= isa
#PROG_DIR = examples
PROG_CONFIG ?= $(TARGET)


