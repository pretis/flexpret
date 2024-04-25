FLEXPRET_ROOT_DIR := ../../..
PROJECT_NAME := leds

include $(FLEXPRET_ROOT_DIR)/fpga/zedboard/board.mk

# Generate the bitstream, which depends on the generated `bitstream_runnable` tcl
# script
# For some reason, make does not detect that the bitstream file already exists,
# so the if statement is there to handle that; generating it when it already
# exists takes quite long time
$(PROJECT_DIR)/bitstream.bit: $(PROJECT_GENERATED_TCL)/bitstream_runnable.tcl
	if [[ ! -e $(PROJECT_DIR)/bitstream.bit ]]; then \
		vivado $(VIVADO_ARGS) -source $<; \
	fi
