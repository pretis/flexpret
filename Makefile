# Makefile for FlexPRET processor
# Set configuration in config.mk or pass variable assignments as arguments.
#
# Usage:
# make verilog_raw: generate raw verilog from Chisel code.
# make emulator: generate a verilator-based FlexPRET emulator.
#
# Authors:
# Michael Zimmer (mzimmer@eecs.berkeley.edu)
# Edward Wang (edwardw@eecs.berkeley.edu)
# Shaokai Lin (shaokai@eecs.berkeley.edu)

# -----------------------------------------------------------------------------
# Standard directory/file locations and naming.
# -----------------------------------------------------------------------------

# Source code location, where subdirectories contain either Chisel
# (used for generating Verilog) or Verilog code.
SRC_DIR = src/main/scala
MODULE = Core

# Directories
FPGA_DIR = fpga
EMULATOR_DIR = emulator
SCRIPTS_DIR = scripts
BUILD_DIR = build
LIB_DIR = programs/lib
RESOURCE_DIR = src/main/resources


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

# Raw Verilog generated from FIRRTL.
VERILOG_RAW = build/$(MODULE).v
verilog_raw: $(VERILOG_RAW)

$(VERILOG_RAW): $(SRC_DIR)/$(MODULE)/*.scala
	sbt 'run "$(CORE_CONFIG)" --no-dedup --target-dir $(BUILD_DIR)'

# Provide rules for simulator
include $(EMULATOR_DIR)/emulator.mk

# Alias
emulator: $(EMULATOR_BIN)


# -----------------------------------------------------------------------------
#  Tests
# -----------------------------------------------------------------------------
unit-test:
	sbt 'test'

# -----------------------------------------------------------------------------
#  Cleanup
# -----------------------------------------------------------------------------

# Remake emulator
remulator: clean emulator

# Clean the emulator and the generated source.
clean:
	rm -rf $(FPGA_DIR)/generated-src
	rm -rf $(FPGA_DIR)/build
	rm -f $(EMULATOR_BIN)
	rm -rf ./build
	rm -rf emulator/obj_dir
	rm -f emulator/Core.sim.v
	rm -f $(LIB_DIR)/include/flexpret_config.h $(LIB_DIR)/linker/flexpret_config.ld
	rm -rf out
	

# Clean for all configurations, targets, and test outputs.
cleanall:
	rm -rf $(FPGA_DIR)/generated-src
	rm -rf $(FPGA_DIR)/build
	rm -f $(EMULATOR_BIN)
	rm -rf ./build
	rm -rf emulator/obj_dir
	rm -f emulator/$(MODULE).sim.v
	rm -rf out
	rm -f firrtl.jar
	rm -f mill
	rm -rf out
	rm -rf test_run_dir
	cd $(TEST_DIR) && $(MAKE) clean

.PHONY: run fpga emulator remulator firrtl_raw verilog_raw clean cleanall test
