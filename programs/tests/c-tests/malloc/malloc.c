#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include "tinyalloc.h"

int main() {
    extern char end; // Set by linker.

    // Byte-addressable.
    ta_init(&end,       // start of the heap space
            &end+4*20,  // end of the heap space >= &end + 4 * (max heap block * alignment + 4)
            4,          // maximum heap blocks: 4, since we call ta_alloc() 4 times. 
            4,          // split_thresh: 4 bytes (Only used when reusing blocks.)
            4);         // alignment: 4 bytes (FlexPRET is a 32-bit architecture.)

    uint32_t* a = ta_alloc(sizeof(uint32_t));
    uint32_t* b = ta_alloc(sizeof(uint32_t));
    uint32_t* c = ta_alloc(sizeof(uint32_t));
    uint32_t* d = ta_alloc(sizeof(uint32_t));

    *a = 100;
    *b = 200;
    *c = 300;
    *d = *a + *b + *c;

    _fp_print(*a);
    _fp_print(*b);
    _fp_print(*c);
    _fp_print(*d);

    ta_free(a);
    ta_free(b);
    ta_free(c);
    ta_free(d);

    // Terminate the simulation
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}
