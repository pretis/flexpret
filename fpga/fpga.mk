NCORES ?= $(shell nproc --all)
PROJECT_DIR := $(FLEXPRET_ROOT_DIR)/fpga/$(BOARD_NAME)/$(PROJECT_NAME)
PROJECT_TCL_DIR := $(PROJECT_DIR)/tcl
PROJECT_GENERATED_DIR := $(PROJECT_TCL_DIR)/generated

VERILOG_SOURCES ?= \
	$(FLEXPRET_ROOT_DIR)/src/main/resources/DualPortBramFPGA.v \
	$(FLEXPRET_ROOT_DIR)/build/FpgaTop.v

IMEM_FILE ?= \
	$(FLEXPRET_ROOT_DIR)/programs/tests/c-tests/bootloader/bootloader.mem

VIVADO_ARGS ?= -mode batch -journal $(PROJECT_DIR)/vivado/vivado.jou -log $(PROJECT_DIR)/vivado/vivado.log

all: flash

flash: $(PROJECT_DIR)/bitstream.bit $(PROJECT_GENERATED_DIR)/flash_runnable.tcl
	vivado $(VIVADO_ARGS) -source $(PROJECT_GENERATED_DIR)/flash_runnable.tcl

$(PROJECT_DIR)/bitstream.bit: $(PROJECT_GENERATED_DIR)/bitstream_runnable.tcl
	cp $(VERILOG_SOURCES) $(PROJECT_DIR)/rtl
	mv rtl/FpgaTop.v rtl/flexpret.v
	cp $(IMEM_FILE) rtl/ispm.mem
	if [[ ! -e $(PROJECT_DIR)/bitstream.bit ]]; then \
		vivado $(VIVADO_ARGS) -source $<; \
	fi

clean::
	rm -f $(PROJECT_DIR)/bitstream.bit


include $(FLEXPRET_ROOT_DIR)/fpga/generate.mk
