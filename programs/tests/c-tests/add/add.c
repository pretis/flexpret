#include <stdint.h>
#include "flexpret.h"

uint32_t add(uint32_t a, uint32_t b) {
    return a + b;
}

int main() {
    
    uint32_t x = 1;
    printf("x is %i\n", x);
    uint32_t y = 2;
    printf("y is %i\n", y);

    uint32_t z = add(x, y);
    printf("z is %i\n", z);
    assert(z == 3);

    return 0;
}

