// Example C program to write, mask set, and mask clear GPIO bits.
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "flexpret_timing.h"
#include "flexpret_io.h"

int main(void)
{
    gpo_write_0(0x1);
    set_compare(get_time() + 10000);
    delay_until();
    gpo_set_0(0x2);
    gpo_clear_0(0x1);
    // should be 2
    debug_string(itoa_hex(gpo_read_0()));
    debug_string("\n")
    return (gpo_read_0() == 0x2);
}

