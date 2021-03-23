# Compile malardalen WCET suite and generate additional files.
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

default: all

PROG = $(TESTS_MALARDALEN)
C = 1
include ../tests.make

#$(eval $(call COMPILE_TEMPLATE,test,$(BUILD_DIR)/test,$(PROG),sim $(C_STARTUP),-Xlinker -defsym -Xlinker TEXT_START_ADDR=0x2000000 -Xlinker -defsym -Xlinker DATA_START_ADDR=0x4000000 -T $(TESTS_DIR)/include/layout.ld))

all: hard boot test

.PHONY: all
