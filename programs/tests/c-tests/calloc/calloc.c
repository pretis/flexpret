#define TA_MAX_HEAP_BLOCK   10
#define TA_ALIGNMENT        4

#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include "tinyalloc.h"

int main() {
    extern char end;    // Set by linker.

    _fp_print(111);     // Marks the start of the execution.
    _fp_print((uint32_t)&end); // 0x20000014

    // Byte-addressable.
    ta_init( 
        &end, // start of the heap space
        // Magic formula that seems to work:
        // heap limit >= &end + 4 * (max heap block * alignment + 4)
        &end + 4 * (TA_MAX_HEAP_BLOCK * TA_ALIGNMENT + 4),
        TA_MAX_HEAP_BLOCK, 
        16, // split_thresh: 16 bytes (Only used when reusing blocks.)
        TA_ALIGNMENT
    );

    // Allocate an array
    int length = TA_MAX_HEAP_BLOCK;
    uint32_t *arr = ta_calloc(length, sizeof(uint32_t));
    for (uint32_t i = 0; i < length; i++) {
        arr[i] = i;
    }
    for (uint32_t j = 0; j < length; j++) {
        _fp_print(arr[j]);
    }

    // Free the memory.
    ta_free(arr);

    // Terminate the simulation
    _fp_print(999);
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}
