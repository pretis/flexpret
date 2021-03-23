# DSPM Program 
# Test operation of DSPM on FPGA with LEDs
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "io.h"

# Addresses for memory-mapped IO.
        DEFINITIONS

# Start of text section.
        START

# DSPM program.
#dspm_start:
#        li x2, 2
#        li x3, 3
#        li sp, 0x04001FF8
#        sw x2, 0(sp)
#        addi sp, sp, -4
#        sw x3, 0(sp)
#        addi sp, sp, 4
#        lw v0, 0(sp)
#        jalr.r x0, ra, 0

dspm_start:
        li x2, 2
        li x3, 3
        li sp, 0x04001FF8
        sw x2, 0(sp)
        addi sp, sp, -4
        sw x3, 0(sp)
        addi sp, sp, 4
        lw x4, 0(sp)
        la x5, LED_NESW
        sb x4, 0(x5)
inf:    beq x0, x0, inf

#dspm_start:
#        la sp, 0x04001FF8
#        sw ra, 0(sp)
#        add sp, sp, -4
#        li v0, 3
#        #sw v0, (sp)
#        add sp, sp, 4
#        lw ra, 0(sp)
#        jalr.r x0, ra, 0

#blink_start:
#
#        la x2, LED_NESW # LED Address
#        li x3, 3 # LED
#blink:
#        li x4, 2000000 # Timeout
#        sb x3, 0(x2) # Set LED
#        xori x3, x3, 0xF
#decr:
#        addi x4, x4, -1
#        bne x0, x4, decr
#        j blink
