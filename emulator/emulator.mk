# Helper fragment to help run flexpret with verilator.
# Authors:
# Edward Wang <edwardw@eecs.berkeley.edu>
# Shaokai Lin <shaokai@berkeley.edu>

EMULATOR_BIN = $(EMULATOR_DIR)/fp-emu
HDL_SCRIPTS = $(SCRIPTS_DIR)/hdl

$(EMULATOR_BIN): $(VERILOG_RAW) $(EMULATOR_DIR)/main.cpp $(HDL_SCRIPTS)/simify_verilog.py
	# Inject the right simulation constructs
	# FIXME: Remove this alltogether, currently only used for  enabling tracing
	$(HDL_SCRIPTS)/simify_verilog.py $(VERILOG_RAW) > $(EMULATOR_DIR)/$(MODULE).sim.v
	

	(cd $(EMULATOR_DIR) && verilator --cc $(MODULE).sim.v --exe --trace --build main.cpp)

	cp $(EMULATOR_DIR)/obj_dir/V$(MODULE) $(EMULATOR_BIN)

	echo "Emulator usage: Run '$(EMULATOR_BIN)'. The emulator expects to find the program for each core stored in the directory it is invoked from with the names 'core1.mem', 'core2.mem', 'coreN.mem' etc. The programs can be built using 'scripts/c/riscv_build.sh coreN <C files...>'. The emulation will generate a VCD called 'trace.vcd'. Use flexpret_io.h to print or to terminate simulation."
