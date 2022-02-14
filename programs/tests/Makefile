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

# check RISCV environment variable
ifndef RISCV
$(Error: Please set environment variable RISCV to the installation path of RISCV tool binaries.)
endif


#--------------------------------------------------------------------
# Build emulator
#--------------------------------------------------------------------

$(emu):
	cd $(base_dir) && $(MAKE) emulator


#--------------------------------------------------------------------
# Run assembly tests and benchmarks
#--------------------------------------------------------------------


# FIXME: To remove and replaced by a hex target. 
riscv-tests:
	cd $(riscv_tests_dir) \
	&& git submodule update --init --recursive \
	&& autoconf \
	&& ./configure --prefix=${RISCV}/target \
	&& make

# FIXME: To remove and replaced by a hex target. 
c-tests:
	# Call the compile script.
	# FIXME: Compile all the source code in the subdirectories.
	# Reference Rocket chip for implementation
	$(scripts_dir)/c/riscv_build.sh $(c_tests_dir)/bin/fib $(c_tests_dir)/fib/fib.c

basic-c-tests = \
	fib \
	fib2

$(addprefix $(c_tests_dir)/, $(addsuffix .hex, $(basic-c-tests))): $(c_tests_dir)/%.hex
	@echo "Hii: $< $@ $(addsuffix .hex, $(basic-c-tests))"
	# FIXME: How to get individual c test name?
	$(scripts_dir)/c/riscv_build.sh $(c_tests_dir)/$(basic-c-tests) $(c_tests_dir)/fib/fib.c
	
# FIXME: to complete running RISCV tests.
# $(output_dir)/riscv-tests/%.out: $(output_dir)/% $(emu)
#	./$(emu) +max-cycles=$(timeout_cycles) $< 2> /dev/null 2> $@ && [ $$PIPESTATUS -eq 0 ]

# FIXME: .out contains the printf via the tohost csr,
# instead of the cycle-by-cycle info, which is implemented in Rocketchip.
$(c_tests_dir)/%.out: $(c_tests_dir)/%.hex $(emu_dir)/$(emu)
	@echo "Running $<"
	$(emu_dir)/$(emu) $< 2> /dev/null 2> $@

run-c-tests: $(addprefix $(c_tests_dir)/, $(addsuffix .out, $(basic-c-tests)))
	@echo "Hi: $^"



#--------------------------------------------------------------------
# General 
#--------------------------------------------------------------------

all: $(emu)
	@echo "Building everything"

clean:
	cd $(riscv_tests_dir) && $(MAKE) clean

clean-all:
	cd $(base_dir) && $(MAKE) clean

.PHONY: run-c-tests
