# Generic Makefile fragment for generating FPGA Verilog code from Chisel code.
#
# The following variables must be defined by the Makefile that includes this
# fragment ([...] contains default value):
# VERILOG: Path to generated verilog code
# MODULE: Chisel top-level component
# FPGA_SRC_DIR: Generated Verilog directory
# SRC_DIR: Chisel source code directory
# CORE_CONFIG: Configuration string for Chisel
# SBT: sbt command
# SBT_TO_BASE: Relative directory location
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)


#-------------------------------------------------------------------------------
# Generate Verilog Code
#-------------------------------------------------------------------------------
$(VERILOG): $(SRC_DIR)/$(MODULE)/*.scala
	cd $(SBT_DIR) && \
	$(SBT) "project Core" "run $(CORE_CONFIG) --backend v --targetDir $(SBT_TO_BASE)/$(FPGA_SRC_DIR)"
	sed -i -e '/^module ISpm/,/^endmodule/ s/\(reg \[31:0\] ispm \[\(.*\):0\];\)/\1  initial $$readmemh(\"ispmfile\", ispm, 0, \2);/g' $(VERILOG)
	sed -i -e '/^module DSpm/,/^endmodule/ s/\(reg \[31:0\] dspm \[\(.*\):0\];\)/\1  initial $$readmemh(\"dspmfile\", dspm, 0, \2);/g' $(VERILOG)
	cp $(VERILOG) fpga/generated-src/Core.v
	

