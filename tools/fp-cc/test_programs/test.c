/**
 * Program to test cycle counting capability.
 * It derives from `mt-benchmarks` branch, `programs/mt-benchmarks/predictability/`.
 **/

#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_csrs.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

#define N 100
#define MASK 8
#define MASK_OFFSET 2

// Array of results, with NUM_THREADS lines and MASK raws
// This will avoid concurrent access when printing to the terminal
uint32_t array_of_results[MASK];

/////////////////////////////////////////////////
int main() {
    uint32_t start_cycle, stop_cycle;
    int mask, i, sum, ir = 0;
    // @BEGIN CYCLE COUNT: L1
    for (mask = 0; mask < MASK; mask++) {
        // @BEGIN CYCLE COUNT: L2
        start_cycle = rdcycle();
        for (i = 0, sum = 0; i < N; i++) {
            if (i & (mask + MASK_OFFSET))
                sum++;
        }
        stop_cycle = rdcycle();
        // @END CYCLE COUNT: L2
        array_of_results[mask] = stop_cycle - start_cycle;
    }
    // @END CYCLE COUNT: L1

    
    for (i = 0; i < MASK ; i++) {
        _fp_print(111111);
        _fp_print(i+MASK_OFFSET); // This is the mask
        _fp_print(array_of_results[i]); // This is the number of cycles
    }
}
