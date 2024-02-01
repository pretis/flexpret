FPGA_PROJECT_NAME := fp-bootloader
FPGA_PROGRAM_NAME := bootloader
FPGA_PROGRAM_PATH := $(FLEXPRET_ROOT_DIR)/programs/tests/c-tests/$(FPGA_PROGRAM_NAME)/$(FPGA_PROGRAM_NAME).mem

$(FPGA_PROGRAM_NAME): 
	make -C programs/tests/c-tests/$(FPGA_PROGRAM_NAME) clean all APP_NAME=wb_uart_led TARGET=fpga
	cp $(FPGA_PROGRAM_PATH) fpga/$(FPGA_BOARD)/$(FPGA_PROJECT_NAME)/ispm.mem
