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

#define PERIOD 10000
#define HIGH1 7500
#define HIGH0 2500

// TODO extern for message

int duty_comm()
{
    char message[4] = {'t','e','s','t'};
    unsigned int i, j; // loop counters
    char curr_byte; // current curr_byte
    unsigned int time = get_time(); // used for period loop
    for(i = 0; i < 4; i++) { // iterate over array of curr_bytes
        curr_byte = message[i];
        for(j = 0; j < 8; j++) {
            // 1 is mask for gpio(0)
            gpio_set(1); // go high
            if(curr_byte & 1) {
                delay_until(time + HIGH1);
                gpio_clear(1); // if bit == 1, stay high for .75*PERIOD
            } else {
                delay_until(time + HIGH0);
                gpio_clear(1); // else bit == 0, stay high for .25*PERIOD
            }
            curr_byte = curr_byte >> 1; // Setup next bit
            periodic_delay(&time, PERIOD); // wait PERIOD since last delay
        }
    }
    return 1;
}

int main(void)
{
    return duty_comm();
}

