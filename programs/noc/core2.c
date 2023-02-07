#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_noc.h>

// Gonna assume that listener is core1

int main() {
    _fp_print(42);
    uint32_t read;
    for (int i=0; i<10; i++) {
        noc_receive(&read, TIMEOUT_FOREVER);
        _fp_print(read);
    }
}