#include <flexpret.h>
#include <stdlib.h>
#include "../../c-tests/interrupt/interrupt.h"

void run_simultaneous_tests(const int n, void *(*test)(void *)) {
    fp_thread_t *threads = malloc(n * sizeof(fp_thread_t));
    fp_assert(threads, "Could not malloc threads\n");
    for (int i = 0; i < n; i++) {
        fp_assert(
            fp_thread_create(HRTT, &threads[i], test, NULL) == 0,
            "Could not create thread %i\n", i+1
        );
    }

    for (int i = 0; i < n; i++) {
        fp_thread_join(threads[i], NULL);
    }

    free(threads);
}

#define do_run(nthreads, test) do { \
    run_simultaneous_tests(nthreads, test); \
    printf(#test " passed for %i hw threads running simultaneously\n", nthreads); \
    reset_flags(); \
} while (0)

int main(void) {
    int nthreads = NUM_THREADS-1;

    do_run(nthreads, test_two_interrupts);
    do_run(nthreads, test_two_interrupts);
    do_run(nthreads, test_disabled_interrupts);
    do_run(nthreads, test_low_timeout);
    do_run(nthreads, test_fp_delay_until);
    do_run(nthreads, test_fp_wait_until);
}
