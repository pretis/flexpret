// Run sync_comm() and duty_comm() on different hardware threads.

#include "flexpret_threads.h"
#include "flexpret_timing.h"
#include "flexpret_io.h"

#define PERIOD 10000
#define HIGH1 7500
#define HIGH0 2500
//#define PERIOD 1000000000
//#define HIGH1 750000000
//#define HIGH0 250000000

void sync_comm()  
{
    char message[4] = {'t','e','s','t'};
    unsigned int i, j; // loop counters
    char curr_byte; // current curr_byte
    unsigned int time = get_time(); // used for period loop
    for(i = 0; i < 4; i++) { // iterate over array of curr_bytes
        curr_byte = message[i];
        for(j = 0; j < 8; j++) {
            // 1 is mask for gpo_1(0)
            // 2 is mask for gpo_1(1)
            gpo_set_1(1); // posedge clk
            if(curr_byte & 1) {
                gpo_set_1(2); // if bit == 1, gpo_1(1) = 1
            } else {
                gpo_clear_1(2); // else bit == 0, gpo_1(1) = 0
            }
            curr_byte = curr_byte >> 1; // Setup next bit
            delay_until_periodic(&time, PERIOD/2); // wait PERIOD/2 since last delay
            gpo_clear_1(1); // negedge clk
            delay_until_periodic(&time, PERIOD/2); // wait PERIOD/2 since last delay
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
            // 1 is mask for gpo_2(0)
            gpo_set_2(1); // go high
            if(curr_byte & 1) {
                set_compare(time + HIGH1);
                delay_until();
                gpo_clear_2(1); // if bit == 1, stay high for .75*PERIOD
            } else {
                set_compare(time + HIGH0);
                delay_until();
                gpo_clear_2(1); // else bit == 0, stay high for .25*PERIOD
            }
            curr_byte = curr_byte >> 1; // Setup next bit
            delay_until_periodic(&time, PERIOD); // wait PERIOD since last delay
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
    gpo_set_0(3);
    return 1;
}
