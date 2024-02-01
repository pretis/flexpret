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
APP := app/$(APP_NAME).mem

DEPENDENCIES := $(BOOTLOADER) $(APP)

# Calculate the size of the bootloader, which is used by the bootloader itself
# Since the bootloader needs this value, we essentially need to compile it twice:
# 1st time to know its size and 2nd time to pass its own size to it at compile time.

# Get the number of lines in the bootloader.mem file
APP_START_ADDR_PART := $(shell make -C $(BOOTLOADER_NAME) TARGET=$(TARGET) clean all > /dev/null && wc -l $(BOOTLOADER) | awk '{print $$1}' && make -C $(BOOTLOADER_NAME) clean > /dev/null)

# Add 1 to this number and multiply by four to get the address of where the application
# will be placed
APP_START_ADDR := $(shell echo $$(($(APP_START_ADDR_PART) * 4)))

all: $(PROJECT_NAME).mem app/$(APP_NAME).dump check

# Make the bootloader with the specified start address and the app with 
# a specific linker script
# Move the compiled program out of the app's folder to avoid confusion; these
# will not run without a bootloader
$(DEPENDENCIES): $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld
	@make -C $(BOOTLOADER_NAME) all START_ADDR=$(APP_START_ADDR) TARGET=$(TARGET)
	@make -C ../$(APP_NAME)/ all LINKER_SCRIPT=$(FP_LIB_DIR)/linker/flexpret_app.ld TARGET=$(TARGET)
	@mkdir -p app
	@mv ../$(APP_NAME)/$(APP_NAME).dump ../$(APP_NAME)/$(APP_NAME).map ../$(APP_NAME)/$(APP_NAME).mem ../$(APP_NAME)/$(APP_NAME).mem.orig ../$(APP_NAME)/$(APP_NAME).riscv app

$(APP).serialized: $(APP)
	@python3 $(FLEXPRET_ROOT_DIR)/scripts/serialize_app.py $(APP) $(APP).serialized

# Combine bootloader with application
$(PROJECT_NAME).mem: $(DEPENDENCIES) $(APP).serialized
	@cat $(DEPENDENCIES) > $(PROJECT_NAME).mem

# FIXME: Find a way to compare the bash variable with the make variable.
# I cannot seem to find a way to do so at the moment...
# The makefile needs to exit if they are different
.ONESHELL:
check: $(BOOTLOADER)
	@len=$$(wc -l $(BOOTLOADER) | awk '{print $$1}')
	@start_addr=$$(($$len * 4))
	@echo ""
	@echo "1st time got size: $(APP_START_ADDR)"
	@echo "2nd time got size: $$start_addr"
	@echo "If these two are not equal you must stop immediately"
	@echo ""

clean:
	@make -C $(BOOTLOADER_NAME) clean
	@make -C ../$(APP_NAME)/ clean
	@rm -rf app
	@rm -f $(PROJECT_NAME).mem
	@rm -f $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld

run: $(PROJECT_NAME).mem
	@$(EMU) +ispm=$(PROJECT_NAME).mem

flash:
	@echo "The bootloader cannot be flashed to an FPGA; it must be uploaded within an FPGA image. This is the piece of software that enables other software to be flashed."

# Generate a file which contains the bootloader configuation. This is necessary
# so the app may use the START_ADDR in its linker script.
define BOOTLOADER_LDSCRIPT
/**
* This flexpret core config file is auto-generated, and based on the
* configuration of the compiled bootloader.
*
* Do not edit.
*
*/

BOOTLOADER_APP_START_ADDR = ${APP_START_ADDR} ;
endef
export BOOTLOADER_LDSCRIPT

$(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld:
	echo "$$BOOTLOADER_LDSCRIPT" > $@
