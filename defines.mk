include ${FLEXPRET_ROOT_DIR}/config.mk

ifeq ($(TARGET), emulator)
DEFINES += -D __EMULATOR__
else ifeq ($(TARGET), fpga)
DEFINES += -D __FPGA__
endif

ifeq ($(DEBUG), true)
DEFINES += -D  DEBUG
else ifeq ($(DEBUG), false)
DEFINES += -D NDEBUG
endif

# For configuration of newlib's reentracy feature; see comments in
# https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
ifeq ($(THREADS),1)
DEFINES += -D __SINGLE_THREADED__
else
DEFINES += -D __DYNAMIC_REENT__
endif

PRINTF_DEFINES := -D PRINTF_ALIAS_STANDARD_FUNCTION_NAMES_SOFT \
				  -D PRINTF_SUPPORT_DECIMAL_SPECIFIERS=0 \
				  -D PRINTF_SUPPORT_EXPONENTIAL_SPECIFIERS=0 \
				  -D SUPPORT_MSVC_STYLE_INTEGER_SPECIFIERS=0 \
				  -D PRINTF_SUPPORT_WRITEBACK_SPECIFIER=0 \
				  -D PRINTF_SUPPORT_LONG_LONG=0

DEFINES := -D _REENT_SMALL $(PRINTF_DEFINES)