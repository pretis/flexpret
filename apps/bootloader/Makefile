FLEXPRET_ROOT_DIR := ../../../..

FP_LIB_DIR := $(FLEXPRET_ROOT_DIR)/programs/lib
EMU ?= $(FLEXPRET_ROOT_DIR)/emulator/fp-emu # Verilator C++ emulator

PROJECT_NAME := bootloader

BOOTLOADER_NAME := loader
BOOTLOADER := $(BOOTLOADER_NAME)/$(BOOTLOADER_NAME).mem

# fpga or emulator
TARGET ?= fpga

# Set this to any application
APP_NAME ?= add
APP_LOCATION ?= ..
APP := app/$(APP_NAME).mem

DEPENDENCIES := $(BOOTLOADER) $(APP)

all: compile
compile: $(PROJECT_NAME).mem app/$(APP_NAME).dump

.ONESHELL:
$(BOOTLOADER):
	@make -C $(BOOTLOADER_NAME) clean all TARGET=$(TARGET)
	@len_1st=$$(wc -l $(BOOTLOADER) | awk '{print $$1}')
	@size_1st=$$((4*$$len_1st))
	@make -C $(BOOTLOADER_NAME) clean all TARGET=$(TARGET) START_ADDR=$$size_1st
	@len_2nd=$$(wc -l $(BOOTLOADER) | awk '{print $$1}')
	@size_2nd=$$((4*$$len_2nd))
	@make -C $(BOOTLOADER_NAME) clean all TARGET=$(TARGET) START_ADDR=$$size_2nd
	@len_3rd=$$(wc -l $(BOOTLOADER) | awk '{print $$1}')
	@size_3rd=$$((4*$$len_3rd))

	@echo ""
	@echo "1st compile size: $$size_1st"
	@echo "2nd compile size: $$size_2nd"
	@echo "3rd compile size: $$size_3rd"
	@echo ""
	
	@if [[ $$size_2nd != $$size_3rd ]]; then \
		RED='\033[0;31m'
		NC='\033[0m'
		printf "$${RED}2nd and 3rd compilations of bootloader had different sizes$${NC}\n" \
		exit 1; \
	fi

	@echo "/**
	* This flexpret core config file is auto-generated, and based on the
	* configuration of the compiled bootloader.
	*
	* Do not edit.
	*
	*/

	BOOTLOADER_APP_START_ADDR = $$size_3rd;" > $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld

$(APP): $(BOOTLOADER)
	@make -C $(APP_LOCATION)/$(APP_NAME)/ all LINKER_SCRIPT=$(FP_LIB_DIR)/linker/flexpret_app.ld TARGET=$(TARGET)
	@mkdir -p app
	@mv $(APP_LOCATION)/$(APP_NAME)/$(APP_NAME).dump $(APP_LOCATION)/$(APP_NAME)/$(APP_NAME).map $(APP_LOCATION)/$(APP_NAME)/$(APP_NAME).mem $(APP_LOCATION)/$(APP_NAME)/$(APP_NAME).mem.orig $(APP_LOCATION)/$(APP_NAME)/$(APP_NAME).riscv app
	
$(APP).serialized: $(APP)
	@python3 $(FLEXPRET_ROOT_DIR)/scripts/serialize_app.py $(APP) $(APP).serialized

# Combine bootloader with application
$(PROJECT_NAME).mem: $(DEPENDENCIES)
	@cat $(DEPENDENCIES) > $(PROJECT_NAME).mem

clean:
	@make -C $(BOOTLOADER_NAME) clean
	@make -C ../$(APP_NAME)/ clean
	@rm -rf app
	@rm -f $(PROJECT_NAME).mem
	@rm -f $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld

run: $(PROJECT_NAME).mem
	@$(EMU) +ispm=$(PROJECT_NAME).mem --allow-imem-store

flash:
	@echo "The bootloader cannot be flashed to an FPGA; it must be uploaded within an FPGA image. This is the piece of software that enables other software to be flashed."
