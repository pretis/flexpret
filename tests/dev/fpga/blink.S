# LED Blink Program 
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "io.h"

# Addresses for memory-mapped IO.
        DEFINITIONS

# Start of text section.
        START

# LED blink program.
blink_start:

        la x2, LED_NESW # LED Address
        li x3, 3 # LED
blink:
        li x4, 2000000 # Timeout
        sb x3, 0(x2) # Set LED
        xori x3, x3, 0xF
decr:
        addi x4, x4, -1
        bne x0, x4, decr
        j blink
