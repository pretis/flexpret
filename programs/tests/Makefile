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
riscv_tests_dir = $(tests_dir)/riscv
c_tests_dir = $(tests_dir)/c
$(info $$tests_dir value -- ${tests_dir})

# Test output dir
output_dir = $(sim_dir)/output
$(info $$output_dir value -- ${output_dir})

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

riscv-benchmarks:
#	cd $(riscv_tests_dir) && $(MAKE) benchmarks

riscv-isa:
#	cd $(riscv_tests_dir) && $(MAKE) isa

riscv-tests: riscv-benchmarks riscv-isa

c-tests:
	# Call the compile script.

#--------------------------------------------------------------------
# Run assembly tests and benchmarks
#--------------------------------------------------------------------

all: flexpret-emulator
	@echo "hello"

clean:
	cd $(base_dir) && $(MAKE) clean

