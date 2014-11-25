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

#define PERIOD 10000
// TODO extern for message

int sync_comm()  
{
    char message[4] = {'t','e','s','t'};
    unsigned int i, j; // loop counters
    char curr_byte; // current curr_byte
    unsigned int time = get_time(); // used for period loop
    for(i = 0; i < 4; i++) { // iterate over array of curr_bytes
        curr_byte = message[i];
        for(j = 0; j < 8; j++) {
            // 1 is mask for gpo(0)
            // 2 is mask for gpo(1)
            gpo_set(1); // posedge clk
            if(curr_byte & 1) {
                gpo_set(2); // if bit == 1, gpo(1) = 1
            } else {
                gpo_clear(2); // else bit == 0, gpo(1) = 0
            }
            curr_byte = curr_byte >> 1; // Setup next bit
            periodic_delay(&time, PERIOD/2); // wait PERIOD/2 since last delay
            gpo_clear(1); // negedge clk
            periodic_delay(&time, PERIOD/2); // wait PERIOD/2 since last delay
        }
    }
    return 1;
}

int main(void)
{
    return sync_comm();
}

