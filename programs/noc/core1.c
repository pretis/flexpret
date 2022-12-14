#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_noc.h>

// Core1 -> Core3
int main() {
    _fp_print(41);
    uint32_t send_values[] = {10,20,30,40,50,60,70,80,90,100};
    uint32_t read;

    // Send values to listener
    for (int i = 0; i<10; i++) {
        noc_send(3, send_values[i]);
    }
}