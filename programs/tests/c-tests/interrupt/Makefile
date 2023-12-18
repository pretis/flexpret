FLEXPRET_ROOT_DIR = ../../../../
NAME = interrupt
APP_SOURCES = interrupt.c
CLIENT = client/stimuli.elf

CLIENT_DIR = $(FLEXPRET_ROOT_DIR)/emulator/clients
INC := $(CLIENT_DIR)
SRC := $(CLIENT_DIR)/common.c client/stimuli.c

include $(FLEXPRET_ROOT_DIR)/Makefrag

# The double colon makes it possible to extend targets
clean::
	rm -f $(CLIENT)

compile:: $(SRC)
	@gcc $^ -o $(CLIENT) -I $(INC)
