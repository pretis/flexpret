#include <stdint.h>
#include <flexpret_io.h>

uint32_t add(uint32_t a, uint32_t b) {
    return a + b;
}

int main() {
    
    uint32_t x = 1;
    _fp_print(x);
    uint32_t y = 2;
    _fp_print(y);

    uint32_t z = add(x, y);
    _fp_print(z);

    return 0;
}

