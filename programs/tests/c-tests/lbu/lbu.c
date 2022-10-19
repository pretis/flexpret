#include <stdint.h>
#include <flexpret_io.h>

int main() {
    
    uint32_t x = 0x10E0; // x = 4320
    uint32_t y = 2;
    _fp_print(x);
    _fp_print(y);

    // Check if basic inline assembly works.
    asm volatile (
    "add %0, %0, %1"
    : "+r"(y)
    : "r"(x)
    );
    _fp_print(y); // y = 4322

    void *p = (void*)0x20004000;

    // Store word
    uint32_t z;
    asm volatile (
    "sw %1, 0(%2)\n\t"
    "lw %0, 0(%2)"
    : "=r"(z)
    : "r"(x), "r"(p)
    );
    _fp_print(z); // z = 4320

    // Check lbu implementation.
    asm volatile (
    "check_lbu: \n\t"
    "lbu %0, 0(%1)"
    : "=r"(z)
    : "r"(p)
    );
    _fp_print(z); // z = 224, i.e. 0x00E0

    return 0;
}

