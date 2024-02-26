FLEXPRET_ROOT_DIR = ../../../../
NAME = interrupt
APP_SOURCES = main.c interrupt.c
CLIENT = client/stimuli.elf
CLIENT_CMD = ./$(CLIENT)

CLIENT_DIR = $(FLEXPRET_ROOT_DIR)/emulator/clients
INC := $(CLIENT_DIR)
SRC := $(CLIENT_DIR)/common.c client/stimuli.c

include $(FLEXPRET_ROOT_DIR)/Makefrag

# The double colon makes it possible to extend targets, e.g., the clean target
# defined in Makefrag gets extended to include this one as well
clean::
	rm -f $(CLIENT)

compile:: $(SRC)
	@gcc $^ -o $(CLIENT) -I $(INC)
