# Makefile fragment for generating C++ emulator from Chisel code.
# Currently intended for only single testbench and Chisel source project.
#
# The following variables must be defined by the Makefile that includes this
# fragment ([...] contains default value):
# EMULATOR: Path to emulator executable
# MODULE: Chisel top-level component
# EMULATOR_SRC_DIR: Generated C++ emulator directory
# EMULATOR_BUILD_DIR: Build directory
# TESTBENCH: C++ testbench path [testbench/$(MODULE)-tb.cpp]
# SRC_DIR: Chisel source code directory
# CORE_CONFIG: Configuration string for Chisel
# SBT: sbt command
# SBT_TO_BASE: Relative directory location
# CXX: C++ compiler
# CXXFLAGS: C++ compiler flags
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)


TESTBENCH ?= $(EMULATOR_DIR)/testbench/$(MODULE)-tb.cpp

ifeq ($(DEBUG), true)
SBT_ARGS = --debug --vcd
endif
#------------------------------------------------------------------------------
# Generate C++ emulator 
#------------------------------------------------------------------------------
# Generate C++ emulator from Chisel code.
$(EMULATOR_SRC_DIR)/$(MODULE).cpp: $(SRC_DIR)/$(MODULE)/*.scala
	cd $(SBT_DIR) && \
	$(SBT) "project Core" "run $(CORE_CONFIG) --backend c --targetDir $(SBT_TO_BASE)/$(EMULATOR_SRC_DIR) $(SBT_ARGS)"

# Create build directory if needed.
$(EMULATOR_BUILD_DIR):
	mkdir -p $(EMULATOR_BUILD_DIR)

# Compile C++ emulator.
$(EMULATOR).o: $(addprefix $(EMULATOR_SRC_DIR)/, $(MODULE).cpp $(MODULE).h emulator.h) | $(EMULATOR_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# Compile testbench.
TESTBENCH_OPTS = $(if $(findstring true, $(FLEXPRET)),-DFLEXPRET) -DTHREADS=$(THREADS)
$(EMULATOR)-tb.o: $(TESTBENCH) $(addprefix $(EMULATOR_SRC_DIR)/, $(MODULE).cpp $(MODULE).h emulator.h) | $(EMULATOR_BUILD_DIR)
	$(CXX) $(CXXFLAGS) -I$(EMULATOR_SRC_DIR) $(TESTBENCH_OPTS) -c $< -o $@

# Link C++ emulator with testbench.
$(EMULATOR): %: %.o %-tb.o
	$(CXX) $(CXXFLAGS) -o $@ $^

