#include <stdlib.h>
#include <stdint.h>
#include "flexpret.h"

int main() {
    // Allocate an array
    int length = 10;
    uint32_t *arr = calloc(length, sizeof(uint32_t));
    
    assert(arr);
    
    // Check that array was initialized to zero
    for (uint32_t i = 0; i < length; i++) {
        assert(arr[i] == 0);
    }

    for (uint32_t i = 0; i < length; i++) {
        arr[i] = i;
    }

    for (uint32_t i = 0; i < length; i++) {
        assert(arr[i] == i);
        printf("arr[%i] = %i\n", i, arr[i]);
    }

    // Free the memory.
    free(arr);

    return 0;
}
