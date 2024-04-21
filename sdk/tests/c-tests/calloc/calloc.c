#include <stdlib.h>
#include <stdint.h>
#include <flexpret/flexpret.h>

int main() {
    // Allocate an array
    uint32_t length = 10;
    uint32_t *arr = calloc(length, sizeof(uint32_t));
    
    fp_assert(arr, "Array allocation unsucessful");
    
    // Check that array was initialized to zero
    for (uint32_t i = 0; i < length; i++) {
        fp_assert(arr[i] == 0, "Array not initialized to zeros");
    }

    for (uint32_t i = 0; i < length; i++) {
        arr[i] = i;
    }

    for (uint32_t i = 0; i < length; i++) {
        fp_assert(arr[i] == i, "Array element not set");
        printf("arr[%i] = %i\n", (int) i, (int) arr[i]);
    }

    // Free the memory.
    free(arr);

    return 0;
}
