FLEXPRET_ROOT_DIR = ../..
EMU=$(FLEXPRET_ROOT_DIR)/emulator/fp-emu
SHELL := /bin/bash
RES_PARSER := $(FLEXPRET_ROOT_DIR)/scripts/test_result_parse.sh

#--------------------------------------------------------------------
# Basic C tests 
#--------------------------------------------------------------------
C_TESTS_DIRS = \
	add \
	calloc \
	fib \
	global \
	malloc \
	realloc \
	lbu \
	syscall \
    gpio \
	hwlock

# Transform list into e.g. c-tests/add/add/out
C_TESTS_RES := $(foreach s,$(C_TESTS_DIRS),c-tests/$(s)/$(s).out)

#--------------------------------------------------------------------
# Multi-threaded C tests 
#--------------------------------------------------------------------
MT_C_TESTS_DIRS = \
	add \
	lockowner \
	swlock \
	printf \
	syscall \
	cond \
	threadcancel 

# Transform list into e.g. c-tests/add/add/out
MT_C_TESTS_RES := $(foreach s,$(MT_C_TESTS_DIRS),mt-c-tests/$(s)/$(s).out)

include $(FLEXPRET_ROOT_DIR)/config.mk

ifeq ($(THREADS),1)
all: run-c-tests
else
all: run-c-tests run-mt-c-tests
endif

# .out file is created from compiled .mem file by running the emulator
%.out: %.mem
	-@set -o pipefail; $(EMU) +ispm=$< | tee $@; $(RES_PARSER) $@ $$?
	

# .mem file is created by compiling using the Makefile in the test dir
%.mem:
	@make -C $(dir $@) compile > /dev/null

# If emulator not present, build the default. 
$(EMU):
	make -C $(FLEXPRET_ROOT_DIR) emulator

# Run single threaded c-tests
run-c-tests: $(EMU) $(C_TESTS_RES)

run-mt-c-tests: $(EMU) $(MT_C_TESTS_RES)

# Remove all generated files by calling make clean in all the test dirs
clean:
	for test in $(C_TESTS_DIRS) ; do \
        make -C c-tests/$$test clean ; \
    done
	
	for test in $(MT_C_TESTS_DIRS) ; do \
        make -C mt-c-tests/$$test clean ; \
    done

.phony: clean run-c-test
