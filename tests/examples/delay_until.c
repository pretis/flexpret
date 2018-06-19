// Example C program for delay_until instruction.
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "flexpret_timing.h"
#include "flexpret_io.h"

int main(void)
{
    int t1 = get_time();
    debug_string(itoa_hex(t1));
    debug_string("\n");
    t1 += 10000; // 1000 cycles
    set_compare(t1);
    delay_until();
    int t2 = get_time();
    debug_string(itoa_hex(t2));
    debug_string("\n");
    return (t2 > t1);
}

