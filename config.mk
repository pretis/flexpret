# Default configuration of core, programs, and target.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

# Default FlexPRET core configuration.
# THREADS=[1-8]: Specify number of hardware threads
# FLEXPRET=[true/false]: Use flexible thread scheduling
# ISPM_KBYTES=[]: Size of instruction scratchpad memory (32 bit words)
# DSPM_KBYTES=[]: Size of instruction scratchpad memory (32 bit words)
# STATS=[true/false]: Count instructions and cycles for each thread
# EXCEPTIONS=[true/false]: Allow exception to interrupt execution
# GET_TIME=[true/false]: Enable instruction to get current time in nanoseconds
# DELAY_UNTIL=[true/false]: Enable instruction to stall until future time
# EXCEPTION_ON_EXPIRE=[true/false]: Enable instruction to interrupt execution at certain time

THREADS ?= 4
#FLEX ?= true
ISPM_KBYTES ?= 16
DSPM_KBYTES ?= 16
#MUL_STAGES ?= 2
#STATS ?= false
EXCEPTIONS ?= false
#GET_TIME ?= false
#DELAY_UNTIL ?= false
#EXCEPTION_ON_EXPIRE ?= false

# Target
# TARGET=[emulator/fpga]: Select default target
# DEBUG=[true/false]: Generate waveform dump.
TARGET ?= emulator
DEBUG ?= true

# Default program compilation
# PROG_DIR=[path]: Directory of programs in tests/ to compile and/or run
# PROG_CONFIG=[]: Program configuration, start with target name
#PROG_DIR ?= complex-mc
#PROG_DIR ?= simple-mc
PROG_DIR ?= isa
PROG_CONFIG ?= $(TARGET)


