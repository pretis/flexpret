// Example C program to write, mask set, and mask clear GPIO bits.
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "flexpret_timing.h"
#include "flexpret_io.h"

int main(void)
{
    gpo_write(0x55);
    gpo_set(0xF0);
    gpo_clear(0x0F);
    debug_string(itoa_hex(gpo_read()));
    debug_string("\n")
    return (gpo_read() == 0xF0);
}

