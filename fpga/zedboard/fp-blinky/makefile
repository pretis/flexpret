FLEXPRET_ROOT_DIR := ../../..
PROJECT_NAME := fp-blinky

IMEM_FILE := $(FLEXPRET_ROOT_DIR)/programs/tests/c-tests/blinky/blinky.mem

include $(FLEXPRET_ROOT_DIR)/fpga/zedboard/board.mk

$(PROJECT_DIR)/bitstream.bit: $(PROJECT_GENERATED_TCL)/bitstream_runnable.tcl
	cp $(VERILOG_SOURCES) $(PROJECT_DIR)/rtl
	mv rtl/FpgaTop.v rtl/flexpret.v
	cp $(IMEM_FILE) rtl/ispm.mem
	if [[ ! -e $(PROJECT_DIR)/bitstream.bit ]]; then \
		vivado $(VIVADO_ARGS) -source $<; \
	fi
