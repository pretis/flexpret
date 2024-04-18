FLEXPRET_ROOT_DIR = ../../../../
NAME = interrupt-delay
APP_SOURCES = *.c

NUMBER_OF_INTERRUPTS := 5
APP_DEFS := -D NINTERRUPTS=$(NUMBER_OF_INTERRUPTS)

CLIENT = $(FLEXPRET_ROOT_DIR)/emulator/clients/build/interrupter.elf

include $(FLEXPRET_ROOT_DIR)/hwconfig.mk

DELAY_BASE = 250

# More hw threads means each interrupt takes longer to execute
DELAY = $(shell echo $$(($(DELAY_BASE) * $(THREADS))))

# This will trigger N interrupts with 1000 ms delay
CLIENT_CMD = ./$(CLIENT) -a -n $(NUMBER_OF_INTERRUPTS) -d $(DELAY)

include $(FLEXPRET_ROOT_DIR)/Makefrag

EMULATOR_DIR := $(FLEXPRET_ROOT_DIR)/emulator
include $(FLEXPRET_ROOT_DIR)/emulator/clients/clients.mk
