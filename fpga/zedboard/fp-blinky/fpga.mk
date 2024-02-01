FPGA_PROGRAM_NAME := blinky
FPGA_PROGRAM_PATH := $(FLEXPRET_ROOT_DIR)/programs/tests/c-tests/$(FPGA_PROGRAM_NAME)/$(FPGA_PROGRAM_NAME).mem

$(FPGA_PROGRAM_NAME): 
	make -C programs/tests/c-tests/$(FPGA_PROGRAM_NAME) clean all TARGET=FPGA
	cp $(FPGA_PROGRAM_PATH) fpga/$(FPGA_BOARD)/fp-blinky/ispm.mem
