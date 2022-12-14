#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_noc.h>

// Core0 -> Core2
int main() {
    _fp_print(40);
    uint32_t send_values[] = {1,2,3,4,5,6,7,8,9,10};
    uint32_t read;

    // Send values to listener
    for (int i = 0; i<10; i++) {
        noc_send(2, send_values[i]);
    }
}