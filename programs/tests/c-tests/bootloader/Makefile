FLEXPRET_ROOT_DIR := ../../../..

FP_LIB_DIR := $(FLEXPRET_ROOT_DIR)/programs/lib
EMU ?= $(FLEXPRET_ROOT_DIR)/emulator/fp-emu # Verilator C++ emulator

BOOTLOADER := bootloader/bootloader.mem

# Set this to any application
APP_NAME := add
APP := app/$(APP_NAME).mem

DEPENDENCIES := $(BOOTLOADER) $(APP)

# Calculate the size of the bootloader, which is used by the bootloader itself
# Since the bootloader needs this value, we essentially need to compile it twice:
# 1st time to know its size and 2nd time to pass its own size to it at compile time.

# Get the number of lines in the bootloader.mem file
APP_START_ADDR_PART := $(shell make -C bootloader clean all > /dev/null && wc -l $(BOOTLOADER) | awk '{print $$1}' && make -C bootloader clean > /dev/null)

# Add 1 to this number and multiply by four to get the address of where the application
# will be placed
APP_START_ADDR := $(shell echo $$((($(APP_START_ADDR_PART) + 1) * 4)))

all: final.mem app/$(APP_NAME).dump

# Make the bootloader with the specified start address and the app with 
# a specific linker script
# Move the compiled program out of the app's folder to avoid confusion; these
# will not run without a bootloader
$(DEPENDENCIES): $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld
	@make -C bootloader all START_ADDR=$(APP_START_ADDR)
	@make -C ../$(APP_NAME)/ all LINKER_SCRIPT=$(FP_LIB_DIR)/linker/flexpret_app.ld
	@mkdir -p app
	@mv ../$(APP_NAME)/$(APP_NAME).dump ../$(APP_NAME)/$(APP_NAME).map ../$(APP_NAME)/$(APP_NAME).mem ../$(APP_NAME)/$(APP_NAME).mem.orig ../$(APP_NAME)/$(APP_NAME).riscv app

# Combine bootloader with application
final.mem: $(DEPENDENCIES)
	@cat $(DEPENDENCIES) > final.mem

clean:
	@make -C bootloader clean
	@make -C ../$(APP_NAME)/ clean
	@rm -rf app
	@rm -f final.mem
	@rm -f $(FP_LIB_DIR)/linker/flexpret_bootloader_config.ld

run: final.mem
	@$(EMU) +ispm=final.mem

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
