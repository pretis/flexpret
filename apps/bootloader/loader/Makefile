# Compiling the bootloader is quite different from compiling any other application
# because we want to reduce the code size

FLEXPRET_ROOT_DIR := ../../../../..
FP_LIB_DIR := $(FLEXPRET_ROOT_DIR)/programs/lib

NAME = loader

ASM_START := $(FP_LIB_DIR)/start.S
BOOTLOADER_SOURCES := \
	$(FP_LIB_DIR)/flexpret_io.c \
	$(FP_LIB_DIR)/flexpret_wb.c \
	$(FP_LIB_DIR)/flexpret_uart.c \
	startup.c \
	$(NAME).c

BOOTLOADER_OBJECTS := $(patsubst %.c,%.o,$(BOOTLOADER_SOURCES))

RISCV_PREFIX = riscv32-unknown-elf-
CC = $(RISCV_PREFIX)gcc
OBJDUMP := $(RISCV_PREFIX)objdump
OBJCOPY := $(RISCV_PREFIX)objcopy

# Beware: This code is heavily duplicated from the top-level makefiles
CFLAGS := -g -static -Os -ffunction-sections -fdata-sections -Wl,--gc-sections -march=rv32i -mabi=ilp32 -nostartfiles --specs=nosys.specs
INCS := -I $(FP_LIB_DIR)/include -I $(FP_LIB_DIR)/printf/src
LDSCRIPT := $(FP_LIB_DIR)/linker/flexpret.ld -L $(FP_LIB_DIR)/linker -Xlinker -Map=$(NAME).map

# We do not want printf in our bootloader; it should be as minimal as possible
WANT_DEBUG := false

# The same goes for stack size
STACKSIZE := 256

# This needs a default value so we can compile the bootloader the first time
# to check its size
# Note: It should not be zero when the bootloader is compiled to know its size.
#		This is because when it is zero, variables that use it to initialize will
#		go into .bss, shrinking the size of the executable and giving an incorrect
#		offset.
# Another note: Having the value set to > 0x800 seems to trigger an optimization.
START_ADDR ?= 0x800

include $(FLEXPRET_ROOT_DIR)/swconfig.mk
include $(FP_LIB_DIR)/Makefrag-lib

.DEFAULT_GOAL: all

all: $(NAME).mem $(NAME).dump

%.o: %.c $(LIB_AUTOGEN)
	@$(CC) $(CFLAGS) -T$(LDSCRIPT) $(INCS) -c $< -o $@ $(DEFINES) -D APP_LOCATION=$(START_ADDR)
	@mkdir -p build
	@mv $@ build

$(NAME).riscv: $(BOOTLOADER_OBJECTS)
	@$(CC) $(CFLAGS) -T$(LDSCRIPT) $(INCS) -o $(NAME).riscv $(ASM_START) build/* $(DEFINES) -D APP_LOCATION=$(START_ADDR)

mem: $(NAME).mem
$(NAME).mem: $(NAME).riscv
	@$(OBJCOPY) -O binary $(NAME).riscv $(NAME).binary.txt
	@xxd -c 4 -e $(NAME).binary.txt | cut -c11-18 > $(NAME).mem
	@xxd -c 4 -e $(NAME).binary.txt > $(NAME).mem.orig
	@rm $(NAME).binary.txt # Delete the temporary binary file

dump: $(NAME).dump app/$(APP_NAME).dump
%.dump: %.riscv
	@$(OBJDUMP) -S -d $^ > $@

clean:
	@rm -f *.dump *.map *.mem *.mem.orig *.riscv
	@rm -rf build
