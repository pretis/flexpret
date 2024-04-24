FLEXPRET_ROOT_DIR := ../../..
PROJECT_NAME := fp-bootloader

include $(FLEXPRET_ROOT_DIR)/fpga/zedboard/board.mk

$(PROJECT_DIR)/bitstream.bit: $(PROJECT_GENERATED_TCL)/bitstream_runnable.tcl $(PROJECT_DIR)/xdc/clock.xdc
	cp $(VERILOG_SOURCES) $(PROJECT_DIR)/rtl
	mv rtl/FpgaTop.v rtl/flexpret.v
	cp $(IMEM_FILE) rtl/ispm.mem
	if [[ ! -e $(PROJECT_DIR)/bitstream.bit ]]; then \
		vivado $(VIVADO_ARGS) -source $<; \
	fi
