#include <stdint.h>
#include "flexpret.h"


int main() {
    uint32_t t1 = rdtime();
    _fp_print(t1);
    uint32_t t2 = rdtime();
    _fp_print(t2);

    assert(t1 < t2);

    uint64_t t3 = rdtime64();
    _fp_print(t3 >> 32);
    _fp_print(t3);
    uint64_t t4 = rdtime64();
    _fp_print(t4 >> 32);
    _fp_print(t4);
    assert(t4 > t3);
}

