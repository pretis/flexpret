# We pass this to Vivado to run FPGA bitstream faster
NCORES ?= $(shell nproc --all)

# Helpful variables to avoid typing out paths
BOARD_DIR := $(FLEXPRET_ROOT_DIR)/fpga/$(BOARD_NAME)
PROJECT_DIR := $(BOARD_DIR)/$(PROJECT_NAME)
BOARD_TCL_DIR := $(BOARD_DIR)/tcl
PROJECT_GENERATED_TCL := $(PROJECT_DIR)/tcl

# We need both the verilog sources and the imem file (which is the compiled program)
# to generate a bistream
VERILOG_SOURCES ?= \
	$(FLEXPRET_ROOT_DIR)/src/main/resources/DualPortBramFPGA.v \
	$(FLEXPRET_ROOT_DIR)/build/FpgaTop.v

IMEM_FILE ?= \
	$(FLEXPRET_ROOT_DIR)/programs/tests/c-tests/bootloader/bootloader.mem

# These are common for all Vivado calls
VIVADO_ARGS ?= -mode batch -journal $(PROJECT_DIR)/vivado/vivado.jou -log $(PROJECT_DIR)/vivado/vivado.log

all: folders flash

folders:
	mkdir -p $(PROJECT_GENERATED_TCL)

# Tranferring the bitstream to FGPA (i.e., flashing) requires the bitstream.bit
# and the generated flash_runnable.tcl script
flash: $(PROJECT_DIR)/bitstream.bit $(PROJECT_GENERATED_TCL)/flash_runnable.tcl
	vivado $(VIVADO_ARGS) -source $(PROJECT_GENERATED_TCL)/flash_runnable.tcl

# Double colon makes it possible to "extend" the target with additional commands
clean::
	rm -f $(PROJECT_DIR)/bitstream.bit

include $(FLEXPRET_ROOT_DIR)/fpga/generate.mk
