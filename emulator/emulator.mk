# Helper fragment to help run flexpret with verilator.
# Authors:
# Edward Wang <edwardw@eecs.berkeley.edu>
# Shaokai Lin <shaokai@berkeley.edu>

EMULATOR_BIN = $(EMULATOR_DIR)/fp-emu
VERILATOR_MODULE=VerilatorTop

$(EMULATOR_BIN): $(VERILOG_VERILATOR) $(EMULATOR_DIR)/main.cpp
	# Copy required resources
	@cp $(VERILOG_VERILATOR) $(EMULATOR_DIR)/$(VERILATOR_MODULE).v
	@cp $(RESOURCE_DIR)/DualPortBram.v $(EMULATOR_DIR)/

	# Build verilator emulator
	@(cd $(EMULATOR_DIR) && verilator --cc $(VERILATOR_MODULE).v --exe --trace --trace-structs --trace-underscore --build main.cpp)
	
	# Copy the emulator binary
	@cp $(EMULATOR_DIR)/obj_dir/V$(VERILATOR_MODULE) $(EMULATOR_BIN)
	@echo "Emulator usage: Run '$(EMULATOR_BIN) --trace +ispm=program.mem'"
