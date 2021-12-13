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
sim_dir = $(base_dir)/emulator
$(info $$sim_dir value -- ${sim_dir})

# Test dir
tests_dir = $(base_dir)/programs/tests
riscv_tests_dir = $(tests_dir)/riscv-tests
c_tests_dir = $(tests_dir)/c-tests
$(info $$tests_dir value -- ${tests_dir})

# Test output dir
output_dir = $(sim_dir)/output
$(info $$output_dir value -- ${output_dir})

# FlexPRET scripts dir
scripts_dir = $(base_dir)/scripts

# check RISCV environment variable
ifndef RISCV
$(Error: Please set environment variable RISCV to the installation path of RISCV tool binaries.)
endif


#--------------------------------------------------------------------
# Build emulator
#--------------------------------------------------------------------

flexpret-emulator:
	cd $(base_dir) && $(MAKE) emulator


#--------------------------------------------------------------------
# Compile the tests and benchmarks 
#--------------------------------------------------------------------

riscv-tests:
	cd $(riscv_tests_dir) \
	&& git submodule update --init --recursive \
	&& autoconf \
	&& ./configure --prefix=${RISCV}/target \
	&& make

c-tests:
	# Call the compile script.
	# FIXME: Compile all the source code in the subdirectories.
	# Reference Rocket chip for implementation
	$(scripts_dir)/c/riscv_build.sh $(c_tests_dir)/bin/fib $(c_tests_dir)/fib/fib.c
	

#--------------------------------------------------------------------
# Run assembly tests and benchmarks
#--------------------------------------------------------------------

# FIXME
$(output_dir)/riscv-tests/%.out:
$(output_dir)/c-tests/%.out:


all: flexpret-emulator
	@echo "Building everything"

clean:
	cd $(riscv_tests_dir) && $(MAKE) clean

clean-all:
	cd $(base_dir) && $(MAKE) clean

.PHONY: riscv-tests
