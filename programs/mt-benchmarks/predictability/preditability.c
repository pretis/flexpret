/**
 * A threaded version of a predictability test. This is useful for playing around
 * the cycle count...
 * 
 * The number of threads executing is set in `NUM_THREADS`.
 *
 * Use the Makefile to clean, build and run the emulator. 
 * Make sure that the FlexPRET was built wih the right number of
 * hardware threads. This can be set in the `config.mk` file, before building
 * the emulator.
 *
 * Currently, the program prints the number of cycles spent in the calculation.
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

// Matrix of results, with NUM_THREADS lines and MASK raws
// This will avoid concurrent access when printing to the terminal
uint32_t array_of_results[NUM_THREADS][MASK];

// Thread function declaration
void* predictability_test_thread();

/////////////////////////////////////////////////
int main() {
    // Thread ids
    thread_t tid[NUM_THREADS];
    int errno[NUM_THREADS], i, j;


    // Create the threads
    for (i = 1; i < NUM_THREADS; i++) {
        errno[i] = thread_create(HRTT, &tid[i], predictability_test_thread, NULL);
        if (errno[i] != 0)
            _fp_print(666);
    }

    // Have hardware thread 0 execute the prediatbility test as well
    predictability_test_thread();

    // Join once the job is done
    void *exit_code[NUM_THREADS];
    for (i = 1; i < NUM_THREADS; i++) {
        thread_join(tid[i], &exit_code[i]);
    }

    for (i = 0; i < NUM_THREADS; i++) {
        for (j = 0; j < MASK ; j++) {
            _fp_print(111111);
            _fp_print(i); // This is the tid
            _fp_print(j+MASK_OFFSET); // This is the mask
            _fp_print(array_of_results[i][j]); // This is the number of cycles
        }
    }
}

// Function to be executed by all hardware threads
void* predictability_test_thread() {
    uint32_t tid = read_hartid();
    uint32_t start_cycle, stop_cycle;
    int mask, i, sum, ir = 0;
    // @BEGIN CYCLE COUNT: L1
    for (mask = 0; mask < MASK ; mask++) {
        // @BEGIN CYCLE COUNT: L2
        start_cycle = rdcycle();
        for (i = 0, sum = 0; i < N; i++) {
            if (i & (mask+MASK_OFFSET))
                sum++;
            }
        stop_cycle = rdcycle();
        // @END CYCLE COUNT: L2
        array_of_results[tid][mask] = stop_cycle-start_cycle;
    }
    // @END CYCLE COUNT: L1
}
