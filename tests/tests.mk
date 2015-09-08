# Compile programs for RISCV and generate additional files.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#VPATH = $(TESTS_DIR)/include $(PROG_SRC_DIR)
VPATH = $(TESTS_DIR)/include:$(PROG_SRC_DIR)

# RISC-V commands.
#RISCV_GCC = riscv-gcc -m32
#RISCV_OBJDUMP = riscv-objdump --disassemble-all --section=.text --section=.data --section=.bss
#RISCV_OBJCOPY = riscv-objcopy
RISCV_GCC = riscv64-unknown-elf-gcc -m32
RISCV_OBJDUMP = riscv64-unknown-elf-objdump --disassemble-all --section=.text --section=.data --section=.bss
RISCV_OBJCOPY = riscv64-unknown-elf-objcopy
RISCV_SPLIT_DATA = $(RISCV_OBJCOPY) --only-section .data --only-section .bss -O binary
RISCV_SPLIT_INST = $(RISCV_OBJCOPY) --only-section .text -O binary
RISCV_TO_MEM = hexdump -v -e '1/4 "%08X" "\n"'

# Default Options.
RISCV_OLEVEL ?= 2
# -ffast-math, -std=gnu99
RISCV_C_OPTS ?= -Wall -O$(RISCV_OLEVEL) -I$(TESTS_DIR)/include
RISCV_S_OPTS ?= -I$(TESTS_DIR)/include
# -fpic: position independent code
#  need to include -lc if -nostdlib used?
RISCV_LD_OPTS ?= -nostdlib -I$(TESTS_DIR)/include -Xlinker -defsym -Xlinker TEXT_START_ADDR=0x00000000 -Xlinker -defsym -Xlinker DATA_START_ADDR=0x20000000 -T

# TODO: support fpga target
LINK_SCRIPT ?= layout.ld

# Default rules for compiling executable.
DEFAULT_RULES = $(eval $(call COMPILE_TEMPLATE,\
				$(PROG),\
				$(C_STARTUP),\
				$(LINK_SCRIPT),\
				$(RISCV_GCC) $(RISCV_S_OPTS),\
				$(RISCV_GCC) $(RISCV_C_OPTS),\
				$(RISCV_GCC) $(RISCV_LD_OPTS),\
				))

#
%.inst: %.elf
	$(RISCV_SPLIT_INST) $< $@

#
%.data: %.elf
	$(RISCV_SPLIT_DATA) $< $@

#
%.inst.mem: %.inst
	$(RISCV_TO_MEM) $(@:.mem=) > $@

#
%.data.mem: %.data
	$(RISCV_TO_MEM) $(@:.mem=) > $@


## 1: Programs
## 2: Object dependencies (shared by all programs)
## 3: Link script
## 4: .S compile command
## 5: .c compile command
## 6: Linker command
## 7: Additional .c line
define COMPILE_TEMPLATE

# Create build directory.
$(PROG_BUILD_DIR):
	mkdir -p $$@

# Compile .S files.
$(PROG_BUILD_DIR)/%.o: %.S | $(PROG_BUILD_DIR)
	$(4) -c $$< -o $$@

# Compile .c files.
$(PROG_BUILD_DIR)/%.o: %.c | $(PROG_BUILD_DIR)
	$(5) -c $$< -o $$@
	$(7)

# Link all files. Generate additional files.
$(1:%=$(PROG_BUILD_DIR)/%.elf): %.elf: $(3) $(2:%=$(PROG_BUILD_DIR)/%.o) %.o
	$(6) $$^ -o $$@
	$(RISCV_OBJDUMP) $$@ > $$(@:.elf=.dump)

endef

