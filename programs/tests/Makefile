FLEXPRET_ROOT_DIR = ../..
EMU=$(FLEXPRET_ROOT_DIR)/emulator/fp-emu


#--------------------------------------------------------------------
# Basic C tests 
#--------------------------------------------------------------------
C_TESTS_DIRS = \
	add \
	fib \
	malloc \
	calloc \
	realloc \
	lbu \
	global \
	syscall \
    gpio \
	hwlock

# Transform list into e.g. c-tests/add/add/out
C_TESTS_RES := $(foreach s,$(C_TESTS_DIRS),c-tests/$(s)/$(s).out)

# Default option.
all: run-c-tests

# .out file is created from compiled .mem file by running the emulator
%.out: %.mem
	$(EMU) $< > $@ 2>&1

# .mem file is created by compiling using the Makefile in the test dir
%.mem:
	make -C $(dir $@) compile

# If emulator not present, build the default. 
$(EMU):
	make -C $(FLEXPRET_ROOT_DIR) emulator	

# Run single threaded c-tests
run-c-tests: $(EMU) $(C_TESTS_RES)

# Remove all generated files by calling make clean in all the test dirs
clean:
	for test in $(C_TESTS_DIRS) ; do \
        make -C c-tests/$$test clean ; \
    done

.phony: clean run-c-test
