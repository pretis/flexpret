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

# Test dir
tests_dir = $(base_dir)/programs/tests
riscv_tests_dir = $(tests_dir)/riscv-tests
c_tests_dir = $(tests_dir)/c-tests
$(info $$tests_dir value -- ${tests_dir})

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

$(emu):
	cd $(base_dir) && $(MAKE) emulator


#--------------------------------------------------------------------
# Run assembly tests and benchmarks
#--------------------------------------------------------------------

# FIXME: To be replaced by a hex target. 
riscv-tests:
	cd $(riscv_tests_dir) \
	&& git submodule update --init --recursive \
	&& autoconf \
	&& ./configure --prefix=${RISCV}/target \
	&& make

# FIXME: to complete running RISCV tests.
# $(output_dir)/riscv-tests/%.out: $(output_dir)/% $(emu)
#	./$(emu) +max-cycles=$(timeout_cycles) $< 2> /dev/null 2> $@ && [ $$PIPESTATUS -eq 0 ]

# FIXME: Add more tests.
basic-c-tests = \
	add \
	fib

define compile_template
$$(c_tests_dir)/$(1).riscv: $(wildcard $$(c_tests_dir)/$(1)/*) $(wildcard $$(clib_dir)/*)
	# Compile the program into .riscv.
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -o $$@ $$(clib_dir)/start.S $(wildcard $(c_tests_dir)/$(1)/*.c) $$(RISCV_LINK_OPTS)
endef

# Expand .riscv targets.
$(foreach test,$(basic-c-tests),$(eval $(call compile_template,$(test))))

# Create .dump.txt files.
$(addprefix $(c_tests_dir)/, $(addsuffix .dump.txt, $(basic-c-tests))): $(c_tests_dir)/%.dump.txt: $(c_tests_dir)/%.riscv
	$(RISCV_OBJDUMP) $< > $@

# Generate .hex files
$(addprefix $(c_tests_dir)/, $(addsuffix .hex, $(basic-c-tests))): $(c_tests_dir)/%.hex: $(c_tests_dir)/%.dump.txt 
	$(scripts_dir)/c/parse_disasm.py $< readmemh > $@
	
# .out files contains the printf via the tohost csr,
# instead of the cycle-by-cycle info, which is implemented in Rocketchip.
$(addprefix $(c_tests_dir)/, $(addsuffix .out, $(basic-c-tests))): $(c_tests_dir)/%.out: $(c_tests_dir)/%.hex $(emu_dir)/$(emu)
	@echo "Running $<"
	$(emu_dir)/$(emu) +ispm=$< > $@ 2>&1

run-c-tests: $(addprefix $(c_tests_dir)/, $(addsuffix .out, $(basic-c-tests)))

#--------------------------------------------------------------------
# General 
#--------------------------------------------------------------------

all: $(emu)

clean:
	cd $(riscv_tests_dir) && $(MAKE) clean
	cd $(c_tests_dir) && rm -f *.out *.dump.txt *.riscv *.hex *.vcd

clean-all: clean
	cd $(base_dir) && $(MAKE) clean

.PHONY: run-c-tests clean clean-all
