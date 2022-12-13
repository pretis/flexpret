# Makefile for FlexPRET processor
# Set configuration in config.mk or pass variable assignments as arguments.
#
# Usage:
# make run: Compile programs located at $(PROG_DIR)/$(PROGS) with 
#   $(PROG_CONFIG) configuration, then execute on target specified by $(TARGET)
#   (either emulator or fpga) FlexPRET core with $(CORE_CONFIG) configuration.
# 
# Optional Usage:
# make fpga: ---
# make all: Same as make $(TARGET)
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)
# Edward Wang (edwardw@eecs.berkeley.edu)

# -----------------------------------------------------------------------------
# Standard directory/file locations and naming.
# -----------------------------------------------------------------------------

# Source code location, where subdirectories contain either Chisel
# (used for generating Verilog) or Verilog code.
SRC_DIR = src/main/scala
MODULE = Top

# FPGA
FPGA_DIR = fpga

EMULATOR_DIR = emulator
SCRIPTS_DIR = scripts
BUILD_DIR = build


# Compiler options.
CXX = g++
CXXFLAGS = -g -O2

# Test directory
TEST_DIR = programs/tests

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
# FPGA
# -----------------------------------------------------------------------------

# Raw Verilog generated from FIRRTL.
VERILOG_RAW = build/$(MODULE).v
verilog_raw: $(VERILOG_RAW)


$(VERILOG_RAW): 
	sbt 'run $(CORE_CONFIG) --target-dir $(BUILD_DIR)'

# FPGA Verilog generation
FPGA_SRC_DIR = $(FPGA_DIR)/generated-src/$(CORE_CONFIG)
VERILOG_FPGA = $(FPGA_DIR)/generated-src/$(MODULE).v
# $(FPGA_SRC_DIR)/$(MODULE).v

# Must provide rules for generating verilog file $(VERILOG)
include $(FPGA_DIR)/fpga.mk

fpga: $(VERILOG_FPGA)

# Provide rules for simulator
include $(EMULATOR_DIR)/emulator.mk

# Alias
emulator: $(EMULATOR_BIN)

# -----------------------------------------------------------------------------
#  Cleanup
# -----------------------------------------------------------------------------

# Clean the emulator and the generated source.
clean:
	rm -rf $(FPGA_DIR)/generated-src
	rm -rf $(FPGA_DIR)/build
	rm -f $(EMULATOR_BIN)
	rm -rf ./build
	rm -rf emulator/obj_dir
	rm -f emulator/Core.sim.v
	rm -rf out
	

# Clean for all configurations, targets, and test outputs.
cleanall:
	rm -rf $(FPGA_DIR)/generated-src
	rm -rf $(FPGA_DIR)/build
	rm -f $(EMULATOR_BIN)
	rm -rf ./build
	rm -rf emulator/obj_dir
	rm -f emulator/Core.sim.v
	rm -rf out
	rm -f fpga/firrtl.jar
	rm -f mill
	rm -rf out
	rm -rf test_run_dir
	cd $(TEST_DIR) && $(MAKE) clean

.PHONY: run fpga emulator firrtl_raw verilog_raw clean cleanall
