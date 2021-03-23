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
$(VERILOG_FPGA): $(VERILOG_RAW)
	mkdir -p $(FPGA_DIR)/generated-src
	cp $(VERILOG_RAW) $(VERILOG_FPGA)

	# TODO: do these in FIRRTL or use the new memory-loading feature of Chisel
	sed -i -e '/^module ISpm/,/^endmodule/ s/\(reg \[31:0\] ispm \[[0-9]*:\([0-9]*\)\];\)/\1  initial $$readmemh(\"ispmfile\", ispm, 0, \2);/g' $(VERILOG_FPGA)
	sed -i -e '/^module DSpm/,/^endmodule/ s/\(reg \[31:0\] dspm \[[0-9]*:\([0-9]*\)\];\)/\1  initial $$readmemh(\"dspmfile\", dspm, 0, \2);/g' $(VERILOG_FPGA)
