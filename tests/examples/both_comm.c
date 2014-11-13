// Run sync_comm() and duty_comm() on different hardware threads.

#include "flexpret_threads.h"
#include "flexpret_timing.h"
#include "flexpret_io.h"

#define PERIOD 10000
#define HIGH1 7500
#define HIGH0 2500

void sync_comm()  
{
    char message[4] = {'t','e','s','t'};
    unsigned int i, j; // loop counters
    char curr_byte; // current curr_byte
    unsigned int time = get_time(); // used for period loop
    for(i = 0; i < 4; i++) { // iterate over array of curr_bytes
        curr_byte = message[i];
        for(j = 0; j < 8; j++) {
            // 1 is mask for gpio(0)
            // 2 is mask for gpio(1)
            gpio_set(1); // posedge clk
            if(curr_byte & 1) {
                gpio_set(2); // if bit == 1, gpio(1) = 1
            } else {
                gpio_clear(2); // else bit == 0, gpio(1) = 0
            }
            curr_byte = curr_byte >> 1; // Setup next bit
            periodic_delay(&time, PERIOD/2); // wait PERIOD/2 since last delay
            gpio_clear(1); // negedge clk
            periodic_delay(&time, PERIOD/2); // wait PERIOD/2 since last delay
        }
    }
    //return 1;
}

void duty_comm()
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
    //return 1;
}

int main() {
    hwthread_start(1, sync_comm, NULL);
    hwthread_start(2, duty_comm, NULL);
    set_slots(SLOT_T0, SLOT_T1, SLOT_T2, SLOT_D, SLOT_D, SLOT_D, SLOT_D,SLOT_D); // tid 0, 1, 2 round robin
    set_tmodes_4(TMODE_HZ, TMODE_HA, TMODE_HA, TMODE_HA); // all hard+active
    while((hwthread_done(1) & hwthread_done(2)) == 0);
    return 1;
}
