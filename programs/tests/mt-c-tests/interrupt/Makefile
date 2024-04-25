FLEXPRET_ROOT_DIR = ../../../../
NAME = interrupt
APP_SOURCES = main.c ../../c-tests/interrupt/interrupt.c
CLIENT = client/stimuli.elf
CLIENT_CMD = ./$(CLIENT)

CLIENT_DIR = $(FLEXPRET_ROOT_DIR)/emulator/clients
INC := $(CLIENT_DIR)
SRC := $(CLIENT_DIR)/common.c client/stimuli.c

include $(FLEXPRET_ROOT_DIR)/Makefrag

clean::
	rm -f $(CLIENT)

compile:: $(SRC)
	@gcc $^ -o $(CLIENT) -I $(INC)
