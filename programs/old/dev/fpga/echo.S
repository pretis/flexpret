# FlexPRET UART Echo
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "io.h"

# Addresses for memory-mapped IO.
        DEFINITIONS
        .equ    UART_TIMEOUT, 4000000   #~500ms

# Start of text section.
        START

# Echo program.
uart_echo_start:
        
        # Setup UART registers.
        jal uart_setup
       
        # Setup LEDs.
        la x2, LED_NESW
        li x3, 0xF

        # Wait for RX byte, then echo.
uart_echo_loop:
        sb x3, 0(x2) # Toggle LEDs
        xori x3, x3, 0xF
        li x5, UART_TIMEOUT
        jal uart_receive_byte # Read a byte
        beq x0, x5, uart_echo_loop
        li x5, UART_TIMEOUT
        jal uart_send_byte # Echo if byte received
        j uart_echo_loop

# Code for UART functions.
        UART_SETUP
        UART_SEND_BYTE
        UART_RECEIVE_BYTE
