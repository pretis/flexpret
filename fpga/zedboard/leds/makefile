FLEXPRET_ROOT_DIR := ../../..
PROJECT_NAME := leds

include $(FLEXPRET_ROOT_DIR)/fpga/zedboard/board.mk

$(PROJECT_DIR)/bitstream.bit: $(PROJECT_GENERATED_DIR)/bitstream_runnable.tcl
	if [[ ! -e $(PROJECT_DIR)/bitstream.bit ]]; then \
		vivado $(VIVADO_ARGS) -source $<; \
	fi
