// Example C program for get_time and delay_until instructions.
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "ptio.h"

int main(void)
{
    int t1 = get_time();
    debug_string(itoa_hex(t1));
    debug_string("\n")
    t1 += 10000; // 1000 cycles
    delay_until(t1);
    sleep_ns(10000);
    int t2 = get_time();
    debug_string(itoa_hex(t2));
    debug_string("\n")
    return (t2 > t1);
}

