#include "macros.h"
#include "pret.h"

#define THREAD 3

int main(void) {
    
    unsigned int ns_h = 0;
    unsigned int ns_l = 100000;
    unsigned int i;
    unsigned int message;

#ifdef emulator_end
    ns_h = 10000;
#endif

    // synchronize.
    delay_until(ns_h, ns_l);

    while(1) {
        message = tohost_id(THREAD, 3); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);

#ifdef emulator_normal
        for(i = 0; i < 155; i++) { 
            taskD_main();
        }
#endif
#ifdef emulator_inf
        while (1);
#endif

        message = tohost_id(THREAD, 13); mtpcr(30, message); 
        message = tohost_time(get_time_low()); mtpcr(30, message);
        add_ms(ns_h, ns_l, 6);
        delay_until(ns_h, ns_l);
    }
    return 0;

}
