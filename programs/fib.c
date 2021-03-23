#include <stdint.h>
#include <flexpret_io.h>

uint32_t fib(uint32_t n) {
    if (n == 0) return 0;
    n--;
    uint32_t a = 0;
    uint32_t b = 1;
    while(n > 0) {
        uint32_t new_b = a + b;
        a = b;
        b = new_b;
        n--;
    }
    return b;
}

int main() {
    _fp_print(fib(16));
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}

