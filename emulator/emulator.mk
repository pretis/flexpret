# Helper fragment to help run flexpret with verilator.
# Authors:
# Edward Wang <edwardw@eecs.berkeley.edu>
# Shaokai Lin <shaokai@berkeley.edu>

EMULATOR_BIN = $(EMULATOR_DIR)/fp-emu
VERILATOR_MODULE=VerilatorTop

$(EMULATOR_BIN): $(VERILOG_VERILATOR) $(EMULATOR_DIR)/main.cpp $(EMULATOR_DIR)/printf_fsm.c $(EMULATOR_DIR)/pin_event.cpp
	# Copy required resources
	@cp $(VERILOG_VERILATOR) $(EMULATOR_DIR)/$(VERILATOR_MODULE).v
	@cp $(RESOURCE_DIR)/DualPortBramEmulator.v $(EMULATOR_DIR)/DualPortBram.v

	# Build verilator emulator
	@(cd $(EMULATOR_DIR) && verilator --cc $(VERILATOR_MODULE).v --exe --trace --trace-structs --trace-underscore --build main.cpp printf_fsm.c pin_event.cpp)
	
	# Copy the emulator binary
	@cp $(EMULATOR_DIR)/obj_dir/V$(VERILATOR_MODULE) $(EMULATOR_BIN)
	@echo "Emulator usage: Run '$(EMULATOR_BIN) --trace +ispm=program.mem'"
