/**
 * @file interrupt-delay.c
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief This test case can be used to benchmark the delay for interrupt
 *        handling. Interrupt can be emulated using the interrupter client
 *        in the emulator folder. Run this program with the --client argument
 *        to connect the client.
 * 
 *        A successful run should give an output looking something like this:
 * 
 * Pin client enabled
 * [0]: Iteration 0: Interrupt: 7823960, {0}: 7828800,
 * [0]: Iteration 1: Interrupt: 8479360, {0}: 8484160,
 * [0]: Iteration 2: Interrupt: 9145200, {0}: 9150080,
 * [0]: Iteration 3: Interrupt: 9812640, {0}: 9817440,
 * [0]: Iteration 4: Interrupt: 10475400, {0}: 10480240,
 * [0]: Iteration 5: Interrupt: 11141320, {0}: 11146160,
 * [0]: Iteration 6: Interrupt: 11806160, {0}: 11810880,
 * [0]: Iteration 7: Interrupt: 12465320, {0}: 12470080,
 * [0]: Iteration 8: Interrupt: 13129000, {0}: 13133840,
 * [0]: Iteration 9: Interrupt: 13795640, {0}: 13800480,
 * [0]: ../../../..//programs/lib/syscalls/syscalls.c: 49: Finish
 *
 * 
 */

#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>

#include <flexpret/flexpret.h>

// Defined in makefile
#ifndef NINTERRUPTS
    #define NINTERRUPTS (10)
#endif // ifndef NINTERRUPTS

#define TIMESTAMP_SIZE (2 * NINTERRUPTS)


static uint64_t *timestamps;
static volatile bool got_int = false;

void isr_timestamp(void)
{
    static int ntimes = 0;
    timestamps[2 * ntimes++ + 0] = rdtime64();
    got_int = true;
}

int main(void)
{
    int ntimes = 0;
    register_isr(EXC_CAUSE_EXTERNAL_INT, isr_timestamp);

    // Using malloc because it can hold bigger arrays for when the number of
    // interrupts becomes very large
    timestamps = malloc(TIMESTAMP_SIZE * sizeof(uint64_t));
    fp_interrupt_enable();

    while (ntimes < NINTERRUPTS) {
        if (got_int) {
            timestamps[2 * ntimes++ + 1] = rdtime64();
            got_int = false;
        }
    }

    fp_interrupt_disable();
 
    for (int i = 0; i < NINTERRUPTS; i++) {
        printf("Iteration %i: Interrupt: %lli, {0}: %lli,\n",
            i, timestamps[2 * i + 0], timestamps[2 * i + 1]);
    }
    free(timestamps);
}
