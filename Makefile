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
# Erling Jellum (erling.r.jellum@ntnu.no)

# -----------------------------------------------------------------------------
# Standard directory/file locations and naming.
# -----------------------------------------------------------------------------

# Source code location, where subdirectories contain either Chisel
# (used for generating Verilog) or Verilog code.
SRC_DIR = src/main/scala

# Directories
FPGA_DIR = fpga
EMULATOR_DIR = emulator
SCRIPTS_DIR = scripts
BUILD_DIR = build
LIB_DIR = programs/lib
RESOURCE_DIR = src/main/resources

VERILOG_VERILATOR = $(BUILD_DIR)/VerilatorTop.v
VERILOG_FPGA = $(BUILD_DIR)/FpgaTop.v

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


all: emulator
# -----------------------------------------------------------------------------
#  Verilator Emulator
# -----------------------------------------------------------------------------
# Generate the raw verilog file for the all targets
$(VERILOG_VERILATOR):
	sbt 'run verilator "$(CORE_CONFIG)" --no-dedup --target-dir $(BUILD_DIR)'

# Provide rules for the emulator
include $(EMULATOR_DIR)/emulator.mk

emulator: $(VERILOG_VERILATOR) $(EMULATOR_BIN)

# -----------------------------------------------------------------------------
#  FPGA
# -----------------------------------------------------------------------------
$(VERILOG_FPGA):
	sbt 'run fpga "$(CORE_CONFIG)" --no-dedup --target-dir $(BUILD_DIR)'

fpga: $(VERILOG_FPGA)

# -----------------------------------------------------------------------------
#  Tests
# -----------------------------------------------------------------------------
unit-test:
	sbt 'test'

integration-test: emulator
	make -C programs/tests tests

test: unit-test integration-test
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
	rm -f emulator/*.v
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

.PHONY: run fpga emulator remulator firrtl_raw verilog_raw clean cleanall test unit-test integration-test
