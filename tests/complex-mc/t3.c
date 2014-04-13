#include "macros.h"
#include "pret.h"

#define THREAD 3

int main(void) {

    unsigned int ns_h = 0;
    unsigned int ns_l = 100000;

    unsigned int message;

    // Synchronize.
    delay_until(ns_h, ns_l);

    while(1) {
        message = tohost_id(THREAD, 4); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        taskA4_main();
        message = tohost_id(THREAD, 14); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        add_ms(ns_h, ns_l, 200);
        delay_until(ns_h, ns_l);
    }
    return 0;
}
