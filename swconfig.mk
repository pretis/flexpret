# This file derives #defines that are ultimately passed to the compiler
# using the -D flag. Many of the #defines are based on the current CPU
# configuration found in config.mk. 

include ${FLEXPRET_ROOT_DIR}/hwconfig.mk

STACKSIZE ?= 4096

# A cumbersome way to calculate log2(STACKSIZE)
STACKSIZE_BITS = $(shell echo ${STACKSIZE} | awk '{print log($$1)/log(2)}')

# Use this variable to configure SW for testing purposes only
TEST_ENVIRONMENT ?= false

# Setting this variable to false will replace all calls to assert with nothing
WANT_DEBUG ?= false

# printf can easily be disabled by setting this variable to false. In that case,
# the printf functions will be replaced with stub versions, taking significantly
# less space.
PRINTF_ENABLED ?= true

PRINTF_DEFINES := -D PRINTF_SUPPORT_DECIMAL_SPECIFIERS=1 \
				  -D PRINTF_SUPPORT_EXPONENTIAL_SPECIFIERS=1 \
				  -D SUPPORT_MSVC_STYLE_INTEGER_SPECIFIERS=1 \
				  -D PRINTF_SUPPORT_WRITEBACK_SPECIFIER=1 \
				  -D PRINTF_SUPPORT_LONG_LONG=1

DEFINES += -D _REENT_SMALL -D PRINTF_ALIAS_STANDARD_FUNCTION_NAMES_SOFT

ifeq ($(PRINTF_ENABLED),true)
DEFINES += $(PRINTF_DEFINES)
endif

ifeq ($(WANT_DEBUG),false)
DEFINES += -D NDEBUG # When NDEBUG is defined, assert() becomes nothing
endif

ifeq ($(TEST_ENVIRONMENT),true)
DEFINES += -D __TEST__
endif

ifeq ($(TARGET),emulator)
DEFINES += -D __EMULATOR__
else ifeq ($(TARGET), fpga)
DEFINES += -D __FPGA__
endif

# For configuration of newlib's reentracy feature; see comments in
# https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
ifeq ($(THREADS),1)
DEFINES += -D __SINGLE_THREADED__
else
DEFINES += -D __DYNAMIC_REENT__
endif

