# FlexPRET Bootloader
# Michael Zimmer (mzimmer@eecs.berkeley.edu)
# David Broman (broman@eecs.berkeley.edu)

#include "io.h"
#include "macros.h"

# Addresses for memory-mapped IO and parameters.
        DEFINITIONS

# Start of text section.
        START
        START_SINGLE_THREAD(x2)

# UART Bootloader.
uart_loader_start:

        # Setup UART registers
        jal uart_setup
        
restart_loader:       
        
start_command_loop:
        # Wait for start command (0xff). Echo if other char.
        # Flash LED
        la x2, LED_NESW # LED memory mapped address
        li x3, 0xF # Initial LED

wait_command_loop:      
        sb x3, 0(x2) # Toggle LEDs 
        xori x3, x3, 0xF
        
        jal uart_receive_byte # Read a byte
        beq x0, x5, wait_command_loop # Restart if timeout
        li x5, 0xFF
        beq x4, x5, send_ready_command # Check if start command
        jal uart_send_byte # Echo if not start command
        j wait_command_loop

        # Send ready to send command (0xfe).
send_ready_command:
        li x4, 0xFE
        jal uart_send_byte
        beq x0, x5, restart_loader

        # Transfer text and data segments.
        la x2, TEXT_ADDR
        jal uart_receive_data
        la x2, DATA_ADDR
        jal uart_receive_data

        # Get scheduling frequency.
        jal uart_receive_word
        beq x0, x5, restart_loader

        la x2, TEXT_ADDR
        SET_SCHEDULING_FREQ(x12, x4, x5)
        RESET_COUNTERS
        jalr x1, x2, 0

        # TODO: terminate string.
        READ_INST_COUNT(x15)
        READ_CYCLE_COUNT(x16)
        li x3, 1
        SET_SCHEDULING_FREQ(x3, x4, x5)
        addi x15, x15, -1
        addi x16, x16, -2
        # Return value.
        move x12, x2
        jal uart_send_word
        beq x0, x5, restart_loader # Restart if timeout
        # Inst count.
        move x12, x15
        jal uart_send_word
        beq x0, x5, restart_loader # Restart if timeout
        # Cycle count.
        move x12, x16
        jal uart_send_word
        beq x0, x5, restart_loader # Restart if timeout
        j restart_loader

        UART_SETUP
        UART_SEND_BYTE
        UART_RECEIVE_BYTE
        UART_SEND_WORD
        UART_RECEIVE_WORD
        UART_RECEIVE_DATA


# Program.
prog:
