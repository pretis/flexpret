include ${FLEXPRET_ROOT_DIR}/config.mk

DEFINES :=

ifeq ($(TARGET),emulator)
DEFINES += -D __EMULATOR__
else ifeq ($(TARGET),fpga)
DEFINES += -D __FPGA__
endif

ifeq ($(DEBUG),true)
DEFINES += -D  DEBUG
else ifeq ($(DEBUG),false)
DEFINES += -D NDEBUG
endif

# For configuration of newlib's reentracy feature; see comments in
# https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
ifeq ($(THREADS),1)
DEFINES += -D __SINGLE_THREADED__
else
DEFINES += -D __DYNAMIC_REENT__
endif

DEFINES += -D _REENT_SMALL