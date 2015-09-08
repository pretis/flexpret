# Makefile for FlexPRET processor
# Set configuration in config.mk or pass variable assignments as arguments.
#
# Usage:
# make run: Compile programs located at $(PROG_DIR)/$(PROGS) with 
#   $(PROG_CONFIG) configuration, then execute on target specified by $(TARGET)
#   (either emulator or fpga) FlexPRET core with $(CORE_CONFIG) configuration.
# 
# Optional Usage:
# make emulator: Generate and compile C++ emulator for FlexPRET core with
#   $(CORE_CONFIG) configuration.
# make fpga: ---
# make all: Same as make $(TARGET)
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)



# -----------------------------------------------------------------------------
# Standard directory/file locations and naming.
# -----------------------------------------------------------------------------

# Source code location, where subdirectories contain either Chisel
# (used for generating Verilog and C++ emulator) or Verilog code.
SRC_DIR = src
MODULE = Core

# C++ emulator location, where subdirectories contain testbenches, generated C++,
# and build files.
EMULATOR_DIR = emulator

# C or ASM test location, where subdirectories contain sets of tests with
# identical compilation configurations.
TESTS_DIR = tests

# FPGA
FPGA_DIR = fpga

# Simple build tool location, used for generating both C++ and Verilog from
# Chisel source code.
SBT_DIR = sbt
SBT_TO_BASE = ..
SBT = java -Xmx1024M -Xss8M -XX:MaxPermSize=128M -jar sbt-launch.jar

# Compiler options.
CXX = g++
CXXFLAGS = -g -O2

# -----------------------------------------------------------------------------
# Core and target configuration
# -----------------------------------------------------------------------------

# Default configuration of core, programs, and target. 
# Override by modifying config.mk or pass varaible assignment as argument.
# See file for description of variables.
include config.mk

# Construct core configuration string (used for directory naming).
# Note: '?=' not used so string is only constructed once.
CORE_CONFIG := $(THREADS)t$(if $(findstring true, $(FLEXPRET)),f)-$(ISPM_KBYTES)i-$(DSPM_KBYTES)d$(if $(findstring true, $(MUL)),-mul)-$(SUFFIX)

# Default will build target and selected programs.
all: $(TARGET)

# -----------------------------------------------------------------------------
# C++ emulator generation and compilation.
# -----------------------------------------------------------------------------

# C++ emulator generation, build, executable locations.
EMULATOR_SRC_DIR = $(EMULATOR_DIR)/generated-src/$(CORE_CONFIG)
EMULATOR_BUILD_DIR = $(EMULATOR_DIR)/build/$(CORE_CONFIG)
EMULATOR = $(EMULATOR_BUILD_DIR)/$(MODULE)

# Must provide rules for generating and compiling C++ emulator $(EMULATOR)
include $(EMULATOR_DIR)/emulator.mk

emulator: $(EMULATOR) 

# -----------------------------------------------------------------------------
# FPGA
# -----------------------------------------------------------------------------

# FPGA Verilog generation
FPGA_SRC_DIR = $(FPGA_DIR)/generated-src/$(CORE_CONFIG)
VERILOG = $(FPGA_SRC_DIR)/$(MODULE).v

# Must provide rules for generating verilog file $(VERILOG)
include $(FPGA_DIR)/fpga.mk

fpga: $(VERILOG)

# -----------------------------------------------------------------------------
# Program compilation.
# -----------------------------------------------------------------------------

# Program source code and build locations.
PROG_CONFIG ?= $(TARGET)
PROG_SRC_DIR = $(TESTS_DIR)/$(PROG_DIR)
PROG_BUILD_DIR = $(TESTS_DIR)/$(PROG_DIR)/build/$(PROG_CONFIG)
PROG_RESULTS_DIR = $(TESTS_DIR)/$(PROG_DIR)/results/$(PROG_CONFIG)/$(CORE_CONFIG)

# Default rules and templates for compilation of programs.
# Note: Comment out to not compile and use existing binaries.
include $(TESTS_DIR)/tests.mk

# Define what programs in selected directory will be compiled and their
# configuration.
# Must provide rules for generating .inst.mem and .data.mem files
include $(TESTS_DIR)/$(PROG_DIR)/test.mk

prog: $(PROG:%=$(PROG_BUILD_DIR)/%.inst.mem) $(PROG:%=$(PROG_BUILD_DIR)/%.data.mem)

# -----------------------------------------------------------------------------
# Running programs on targets.
# -----------------------------------------------------------------------------

ifeq ($(TARGET),emulator)

MAX_CYCLES ?= 20000000
ifeq ($(DEBUG), true)
else
SIM_DEBUG = --vcdstart=$(MAX_CYCLES)
endif

$(PROG:%=$(PROG_RESULTS_DIR)/%.out): $(PROG_RESULTS_DIR)/%.out: $(PROG_BUILD_DIR)/%.inst.mem $(PROG_BUILD_DIR)/%.data.mem $(EMULATOR)
	mkdir -p $(PROG_RESULTS_DIR)
	./$(EMULATOR) --maxcycles=$(MAX_CYCLES) --ispm=$(PROG_BUILD_DIR)/$*.inst.mem --dspm=$(PROG_BUILD_DIR)/$*.data.mem --vcd=$(@:.out=.vcd) $(SIM_DEBUG) $(EMULATOR_OPTS) > $@ 2>&1
	echo $@ $^

# Possible targets are emulator and fpga.
run: $(PROG:%=$(PROG_RESULTS_DIR)/%.out)
	@echo; perl -ne 'print "  [$$1] $$ARGV \t$$2\n" if /\*{3}(.*)\*{3}(.*)/' \
	$^; echo;

CLEAN_TARGET = $(EMULATOR_SRC_DIR) $(EMULATOR_BUILD_DIR) $(PROG_RESULTS_DIR) $(PROG_BUILD_DIR)

endif

# -----------------------------------------------------------------------------
#  Cleanup
# -----------------------------------------------------------------------------

clean:
	rm -rf $(CLEAN_TARGET)
	

# Clean for all configurations and targets.
cleanall:
	rm -rf $(EMULATOR_DIR)/generated-src
	rm -rf $(EMULATOR_DIR)/build
	rm -rf $(FGPA_DIR)/generated-src
	find $(TESTS_DIR) -type d -name "results" -exec rm -rf {} \; \
		find $(TESTS_DIR) -type d -name "build" -exec rm -rf {} \;

.PHONY: run emulator fpga prog clean cleanall
