// Example C program for bit-banging variable duty cycle communication.
//
// This program sends an array of curr_bytes. For each curr_byte, bits are sent from least
// significant to most significant by using either a longer or shorter duty
// cycle than nominal.
// gpio(0): variable duty cycle with PERIOD, logic 1 is 75% high, 0 is 25% high
//
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "flexpret_timing.h"
#include "flexpret_io.h"

#define PERIOD 1200
#define HIGH1 700
#define HIGH0 350

void duty_comm(uint32_t* data, uint32_t length)
{
    uint32_t i, j;                   // loop counters
    uint32_t current;                // current word of data
    uint32_t time = get_time()+1000; // start time after initialization
    for(i = 0; i < length; i++) {    // iterate through input data
        current = data[i];           // read next word
        for(j = 0; j < 32; j++) {    // iterate through each bit in word
            time = time + PERIOD;    
            set_compare(time);
            delay_until();           // wait until next period
            gpo_set_0(1);            // output pin goes high
            if(current & 1) {        // if bit == 1...
                set_compare(time + HIGH1);
                delay_until();       // stay high for .75*PERIOD
                gpo_clear_0(1);      // output bit goes low 
            } else {                 // if bit == 0...
                set_compare(time + HIGH0);
                delay_until();       // stay high for .25*PERIOD
                gpo_clear_0(1);      // output bit goes low
            }
            current = current >> 1;  // setup next bit
        }
    }
}

int main(void)
{
    uint32_t data[2] = {0x01234567, 0x89ABCDEF};
    duty_comm(data,2);
    return 1;
}

