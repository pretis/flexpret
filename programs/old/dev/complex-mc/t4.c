#include "macros.h"
#include "pret.h"

#define THREAD 4

int taskB1_main(void);
int taskB2_main(void);
int taskB3_main(void);

int main(void) {

    unsigned int ns_h = 0;
    unsigned int ns_l = 100000;
    unsigned int i = 0;

    unsigned int message;

    // Synchronize.
    delay_until(ns_h, ns_l);

    while(1) {
        message = tohost_id(THREAD, 1); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        taskB1_main();
        message = tohost_id(THREAD, 11); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        if(i == 0) {
        message = tohost_id(THREAD, 2); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        taskB2_main();
        message = tohost_id(THREAD, 12); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        i++;
        } else {
        message = tohost_id(THREAD, 3); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        taskB3_main();
        message = tohost_id(THREAD, 13); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        i = 0;
        }
        add_ms(ns_h, ns_l, 25);
        delay_until(ns_h, ns_l);
    }
    return 0;
}

