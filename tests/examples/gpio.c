// Example C program to write, mask set, and mask clear GPIO bits.
// Michael Zimmer (mzimmer@eecs.berkeley.edu)

#include "ptio.h"

int main(void)
{
    gpio_write(0x55);
    gpio_set(0xF0);
    gpio_clear(0x0F);
    debug_string(itoa_hex(gpio_read()));
    debug_string("\n")
    return (gpio_read() == 0xF0);
}

