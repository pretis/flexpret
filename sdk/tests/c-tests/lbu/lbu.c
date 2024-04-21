#include <stdint.h>
#include <flexpret/flexpret.h>

#define X_INIT 0x10E0
#define Y_INIT 2

int main() {
    
    int x = X_INIT; // x = 4320
    int y = Y_INIT;
    printf("x is %i\n", x);
    printf("y is %i\n", y);

    // Check if basic inline assembly works.
    asm volatile (
    "add %0, %0, %1"
    : "+r"(y)
    : "r"(x)
    );

    printf("Ran inline assembly that adds places x + y in y\n");
    printf("y is %i\n", y);
    fp_assert(y == (X_INIT + Y_INIT), "Inline assembly add got incorrect value");

    void *p = (void*)0x20004000;

    // Store word
    int z;
    asm volatile (
    "sw %1, 0(%2)\n\t"
    "lw %0, 0(%2)"
    : "=r"(z)
    : "r"(x), "r"(p)
    );

    printf("Ran inline assembly that stores x and loads it into z\n");
    printf("z is %i\n", z);
    fp_assert(z == x, "Inline assembly store and load got incorrect value");

    // Check lbu implementation.
    asm volatile (
    "check_lbu: \n\t"
    "lbu %0, 0(%1)"
    : "=r"(z)
    : "r"(p)
    );

    printf("Ran inline assembly that loads the first byte of x into z\n");
    printf("x = 0x%x\n", x);
    printf("z = 0x%x\n", z);

    fp_assert(z == (X_INIT & 0xFF), "Inline assembly load one byte got incorrect value");

    return 0;
}

