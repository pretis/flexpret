XLEN ?= 32

default: all

# Project root directory
base_dir = $(abspath ../../)
$(info $$base_dir value -- ${base_dir})

# FlexPRET generated source (Verilog)
generated_dir = $(base_dir)/out
$(info $$generated_dir value -- ${generated_dir})

# Verilator C++ emulator
emu = fp-emu
emu_dir = $(base_dir)/emulator
$(info $$emu_dir value -- ${emu_dir})

# Test directories
tests_dir = $(base_dir)/programs/tests
$(info $$tests_dir value -- ${tests_dir})
c_tests_dir = $(tests_dir)/c-tests

# Scripts dir
scripts_dir = $(base_dir)/scripts

# C library dir
clib_dir = $(base_dir)/programs/lib

# check RISCV environment variable
ifndef RISCV
$(Error: Please set environment variable RISCV to the installation path of RISCV tool binaries.)
endif

# Compilation
RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -g -static -O0 -march=rv32i -mabi=ilp32 -nostartfiles -specs=nosys.specs
RISCV_LINK ?= -T ../lib/linker/flexpret.ld
RISCV_LINK_OPTS ?= 
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump
RISCV_OBJDUMP_OPTS ?= -S -d
RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy
RISCV_OBJCOPY_OPTS ?= -O binary

INCS  += -I$(clib_dir)/include
OBJS  :=

#--------------------------------------------------------------------
# Build emulator
#--------------------------------------------------------------------

$(base_dir)/emulator/$(emu):
	cd $(base_dir) && $(MAKE) emulator


#--------------------------------------------------------------------
# Run C tests
#--------------------------------------------------------------------

include $(tests_dir)/Makefrag-tests

#--------------------------------------------------------------------
# General 
#--------------------------------------------------------------------

all: $(base_dir)/emulator/$(emu) run-c-tests

clean:
	cd $(c_tests_dir) && rm -f *.vcd *.mem *.riscv *.map *.out *.dump

cleanall: clean
	cd $(base_dir) && $(MAKE) clean

.PHONY: run-c-tests clean cleanall
