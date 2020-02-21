# Generic Makefile fragment for generating FPGA Verilog code from Chisel code.
#
# The following variables must be defined by the Makefile that includes this
# fragment ([...] contains default value):
# VERILOG: Path to generated verilog code
# MODULE: Chisel top-level component
# FPGA_SRC_DIR: Generated Verilog directory
# SRC_DIR: Chisel source code directory
# CORE_CONFIG: Configuration string for Chisel
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#-------------------------------------------------------------------------------
# Generate Verilog Code
#-------------------------------------------------------------------------------
$(VERILOG): $(SRC_DIR)/$(MODULE)/*.scala $(FIRRTL_JAR) $(MILL_BIN)
	$(MILL_BIN) flexpret.run "$(CORE_CONFIG)" --compiler high --target-dir "$(FPGA_SRC_DIR)"
	# high-firrtl is dumped into $(FPGA_SRC_DIR)/$(MODULE).hi.fir

	# Use FIRRTL to compile to Verilog
	java -cp $(FIRRTL_JAR) firrtl.stage.FirrtlMain --compiler verilog \
		--input-file $(FPGA_SRC_DIR)/$(MODULE).hi.fir \
		--target-dir $(FPGA_SRC_DIR)

	# TODO: do these in FIRRTL or use the new memory-loading feature of Chisel
	sed -i -e '/^module ISpm/,/^endmodule/ s/\(reg \[31:0\] ispm \[[0-9]*:\([0-9]*\)\];\)/\1  initial $$readmemh(\"ispmfile\", ispm, 0, \2);/g' $(VERILOG)
	sed -i -e '/^module DSpm/,/^endmodule/ s/\(reg \[31:0\] dspm \[[0-9]*:\([0-9]*\)\];\)/\1  initial $$readmemh(\"dspmfile\", dspm, 0, \2);/g' $(VERILOG)

	cp $(VERILOG) fpga/generated-src/Core.v
