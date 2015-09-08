#include "macros.h"
#include "pret.h"

#define THREAD 1

int main(void) {

    unsigned int ns_h = 0;
    unsigned int ns_l = 100000;

    unsigned int message;

    // Synchronize.
    delay_until(ns_h, ns_l);

    while(1) {
        message = tohost_id(THREAD, 2); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        taskA2_main();
        message = tohost_id(THREAD, 12); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        add_ms(ns_h, ns_l, 50);
        delay_until(ns_h, ns_l);
    }
    return 0;
}
