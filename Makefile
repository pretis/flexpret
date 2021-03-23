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



# -----------------------------------------------------------------------------
# Standard directory/file locations and naming.
# -----------------------------------------------------------------------------

# Source code location, where subdirectories contain either Chisel
# (used for generating Verilog) or Verilog code.
SRC_DIR = src/main/scala
MODULE = Core

# C or ASM test location, where subdirectories contain sets of tests with
# identical compilation configurations.
TESTS_DIR = tests

# FPGA
FPGA_DIR = fpga

# Mill build tool for compiling and running the Chisel generator.
MILL_VERSION = 0.6.0
MILL_BIN = ./mill
$(MILL_BIN):
	wget https://github.com/lihaoyi/mill/releases/download/$(MILL_VERSION)/$(MILL_VERSION) -O $(MILL_BIN) && chmod +x $(MILL_BIN)

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
# FPGA
# -----------------------------------------------------------------------------

# FIRRTL compiler
FIRRTL_VERSION="1.2.2"
FIRRTL_JAR = $(FPGA_DIR)/firrtl.jar

$(FIRRTL_JAR):
	wget https://github.com/freechipsproject/firrtl/releases/download/v$(FIRRTL_VERSION)/firrtl.jar -O $(FIRRTL_JAR)

# Alias for $(FIRRTL)
firrtl_jar: $(FIRRTL_JAR)

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
#  Cleanup
# -----------------------------------------------------------------------------

clean:
	rm -rf $(CLEAN_TARGET)
	

# Clean for all configurations and targets.
cleanall:
	rm -rf $(FGPA_DIR)/generated-src
	find $(TESTS_DIR) -type d -name "results" -exec rm -rf {} \; \
		find $(TESTS_DIR) -type d -name "build" -exec rm -rf {} \;

.PHONY: run fpga prog clean cleanall
