XLEN ?= 64

default: all

# Project root directory
base_dir = $(abspath ../../)
$(info $$base_dir value -- ${base_dir})

# FlexPRET generated source (Verilog)
generated_dir = $(base_dir)/out
$(info $$generated_dir value -- ${generated_dir})
# FIXME: enable debug
# generated_dir_debug = $(abspath ./generated-src-debug)

# Verilator C++ emulator
emu = flexpret-emulator
emu_dir = $(base_dir)/emulator
$(info $$emu_dir value -- ${emu_dir})

# Test directories
tests_dir = $(base_dir)/programs/tests
$(info $$tests_dir value -- ${tests_dir})
riscv_tests_dir = $(tests_dir)/riscv-tests
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
# RISCV_PREFIX ?= riscv$(XLEN)-unknown-elf-
RISCV_PREFIX ?= riscv-none-embed-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -g -static -O0 -march=rv32i -mabi=ilp32 -specs=nosys.specs -nostartfiles -Wl,-Ttext=0x00000000
RISCV_LINK ?= $(RISCV_GCC) -T $(src_dir)/common/test.ld $(incs)
RISCV_LINK_OPTS ?= 
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump -S -d
RISCV_SIM ?= spike --isa=rv$(XLEN)gc

incs  += -I$(clib_dir)/include
objs  :=

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

all: $(emu)

clean:
	cd $(riscv_tests_dir) && $(MAKE) clean
	cd $(c_tests_dir) && rm -f *.out *.dump.txt *.riscv *.hex *.vcd *.map

cleanall: clean
	cd $(base_dir) && $(MAKE) clean

.PHONY: run-c-tests run-bmark-tests clean cleanall
