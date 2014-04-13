# Printf 
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "io.h"
#include "macros.h"

# Addresses for memory-mapped IO.
        DEFINITIONS

# Start of text section.
        START
        START_SINGLE_THREAD(x2)

        jal uart_setup

        li x4, 0x28
        jal uart_send_byte
        li x4, 0x29
        jal uart_send_byte

        UART_SETUP
        UART_SEND_BYTE

