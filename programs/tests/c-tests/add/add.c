#include <stdint.h>
#include <flexpret_io.h>

uint32_t add(uint32_t a, uint32_t b) {
    return a + b;
}

int main() {
    
    uint32_t x = 1;
    _fp_print(x);
    uint32_t y = 2;
    _fp_print(y); // Prints strange number 0x4E

    uint32_t z = add(x, y);
    _fp_print(z);

    // Terminate the simulation.
    // Put a while loop to make sure no unwanted side effects.
    _fp_finish();
    while(1) {}
    // Not strictly required; just wanted to let the compiler know.
    __builtin_unreachable();
}

