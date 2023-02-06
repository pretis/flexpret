#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_noc.h>

int main() {
    _fp_print(43);
    uint32_t read;
    for (int i=0; i<10; i++) {
        noc_receive(UINT32_MAX, &read);
        _fp_print(read);
    }
}