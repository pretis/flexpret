/**
Example program where core0 blinks the LED which should be connected to port0.
*/
#include <stdint.h>
#include <flexpret/io.h>

void set_ledmask(const uint8_t byte)
{
    gpo_write_0((byte >> 0) & 0b11);
    gpo_write_1((byte >> 2) & 0b11);
    gpo_write_2((byte >> 4) & 0b11);
    gpo_write_3((byte >> 6) & 0b11);
}

int main() {
    uint8_t count = 0;
    while(1) {
        set_ledmask(count++);
        for (int i = 0; i < 100000; i++);
    }
}
