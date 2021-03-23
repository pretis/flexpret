// Example C program for bit-banging synchronous communication.
//
// This program sends an array of curr_bytes. For each curr_byte, bits are sent from least
// significant to most significant by setting the data pin to 0/1 after each
// positive clock edge.
// gpo(0): clock pin, with period PERIOD and ~50% duty cycle
// gpo(1): data pin, 0/1 depending on current bit
//
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "flexpret_timing.h"
#include "flexpret_io.h"

#define PERIOD 1200

void sync_comm(uint32_t* data, uint32_t length)
{
    uint32_t i, j;                   // loop counters
    uint32_t current;                // current word of data
    uint32_t time = get_time()+1000; // start time after initialization
    for(i = 0; i < length; i++) {    // iterate through input data
        current = data[i];           // read next word
        for(j = 0; j < 32; j++) {    // iterate through each bit in word
            time = time + PERIOD/2;    
            set_compare(time);
            delay_until();           // wait half period
            gpo_set_0(1);            // posedge clk on pin
            if(current & 1) {        // if bit == 1...
                gpo_set_0(2);        // output bit goes high
            } else {                 // if bit == 0...
                gpo_clear_0(2);      // output bit goes high
            }
            current = current >> 1;  // setup next bit
            time = time + PERIOD/2;    
            set_compare(time);
            delay_until();           // wait half period
            gpo_clear_0(1);          // negedge clk on pin
        }
    }
}

int main(void)
{
    uint32_t data[2] = {0x01234567, 0x89ABCDEF};
    sync_comm(data,2);
    return 1;
}

