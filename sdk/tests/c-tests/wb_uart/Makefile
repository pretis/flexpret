FLEXPRET_ROOT_DIR = ../../../../
NAME = wb_uart
APP_SOURCES = *.c

TESTFILE := testfile.txt

CLIENT := $(FLEXPRET_ROOT_DIR)/emulator/clients/build/uart.elf
CLIENT_CMD := ./$(CLIENT) --file $(TESTFILE)

$(shell cp $(TESTFILE) file.txt && xxd -i file.txt > file.txt.h)

include $(FLEXPRET_ROOT_DIR)/Makefrag
include $(FLEXPRET_ROOT_DIR)/emulator/clients/clients.mk


