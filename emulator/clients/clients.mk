CLIENT_DIR ?= $(EMULATOR_DIR)/clients
CLIENT_BUILD_DIR  ?= $(CLIENT_DIR)/build
CLIENT_C_SRCS   = interrupter.c uart.c gpio.c
CLIENT_CPP_SRCS = 
COMMON_SRCS = common.c

CLIENTS  = $(patsubst %.c,$(CLIENT_BUILD_DIR)/%.elf,$(CLIENT_C_SRCS))
CLIENTS += $(patsubst %.cpp,$(CLIENT_BUILD_DIR)/%.elf,$(CLIENT_CPP_SRCS))
COMMON   = $(patsubst %.c,$(CLIENT_DIR)/%.c,$(COMMON_SRCS))

$(CLIENT_BUILD_DIR)/%.elf: $(CLIENT_DIR)/%.c | $(CLIENT_BUILD_DIR)
	gcc $< $(COMMON) -o $@

$(CLIENT_BUILD_DIR)/%.elf: $(CLIENT_DIR)/%.cpp | $(CLIENT_BUILD_DIR)
	g++ $< $(COMMON) -o $@

$(CLIENT_BUILD_DIR):
	mkdir -p $(CLIENT_BUILD_DIR)
