# Helper fragment to help run flexpret with verilator.
# Authors:
# Edward Wang <edwardw@eecs.berkeley.edu>
# Shaokai Lin <shaokai@berkeley.edu>

EMULATOR_BIN = $(EMULATOR_DIR)/fp-verilator
HDL_SCRIPTS = $(SCRIPTS_DIR)/hdl

$(EMULATOR_BIN): $(VERILOG_RAW) $(EMULATOR_DIR)/main.cpp $(HDL_SCRIPTS)/simify_verilog.py
	# Inject the right simulation constructs
	# $(HDL_SCRIPTS)/simify_verilog.py $(VERILOG_RAW) > $(EMULATOR_DIR)/Core.sim.v
	
	# Copy required resources
	cp $(VERILOG_RAW) $(EMULATOR_DIR)/$(MODULE).v
	cp $(RESOURCE_DIR)/DualPortBram.v $(EMULATOR_DIR)/

	(cd $(EMULATOR_DIR) && verilator --cc $(MODULE).v --exe --trace --build main.cpp)

	cp $(EMULATOR_DIR)/obj_dir/VCore $(EMULATOR_BIN)

	echo "Emulator usage: Run '$(EMULATOR_BIN) +ispm=<name>.mem'. A .mem file can be generated using 'scripts/c/riscv-compile.sh <thread count> <binary name> <C files...>'. The emulation will generate a VCD in Core.vcd. Use flexpret_io.h to print or to terminate simulation."
