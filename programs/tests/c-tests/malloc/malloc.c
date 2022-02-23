#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include "tinyalloc.h"

int main() {
    extern char end; // Set by linker.

    // Allocate 128 bits (16 bytes) for the heap.
    ta_init(&end, &end+128, 3, 16, 4);

    uint32_t* a = ta_alloc(sizeof(uint32_t));
    uint32_t* b = ta_alloc(sizeof(uint32_t));
    uint32_t* c = ta_alloc(sizeof(uint32_t));
    *a = 100;
    *b = 200;
    *c = *a + *b;

    _fp_print(*c);

    ta_free(a);
    ta_free(b);
    ta_free(c);

    // Terminate the simulation
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}
