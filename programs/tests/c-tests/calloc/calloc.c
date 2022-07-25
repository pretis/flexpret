#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include "tinyalloc.h"

int main() {
    extern char end; // Set by linker.

    _fp_print((uint32_t)&end); // 0x20000014

    // Byte-addressable.
    // Assign 19 4-byte words for the heap.
    ta_init(
        // start of the heap space
        &end,
        // end of the heap space >= &end + 4 *
        // (max heap block * alignment + 3)
        (void*)(0x20000000+0x3E80),
        // maximum heap blocks: 4, since we call ta_alloc() 4 times.
        50,
        // split_thresh: 16 bytes (Only used when reusing blocks.)
        16, 
        // alignment: 4 bytes (FlexPRET is a 32-bit architecture.)
        4
    );

    // Allocate an array
    int length = 100;
    uint32_t *arr = ta_calloc(length, sizeof(uint32_t));
    for (int j = 0; j < length; j++) {
        arr[j] = j;
    }
    for (int i = 0; i < length; i++) {
        _fp_print(arr[i]);
    }

    uint32_t *arr2 = ta_calloc(length, sizeof(uint32_t));
    for (int j = 0; j < length; j++) {
        arr[j] = j;
    }
    for (int i = 0; i < length; i++) {
        _fp_print(arr[i]);
    }

    // Terminate the simulation
    _fp_print(999);
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}
