/**
Example program where core0 blinks the LED which should be connected to port0.
*/
#include <flexpret_io.h>
#include <flexpret_time.h>

#define BLINK_PERIOD 500000000UL

int main() {
    while(1) {
        gpo_write(0, 0xFFFFFFFF);
        for (int i = 0; i < 10000000; i++);
        gpo_write(0, 0x00000000);
        for (int i = 0; i < 10000000; i++);
    }
}
