#include <flexpret/flexpret.h>
#include <stdlib.h>
#include "../../c-tests/interrupt/interrupt.h"

void run_simultaneous_tests(const int n, void *(*test)(void *), void **args) {
    fp_thread_t *threads = malloc(n * sizeof(fp_thread_t));
    fp_assert(threads, "Could not malloc threads\n");
    for (int i = 0; i < n; i++) {
        fp_assert(
            fp_thread_create(HRTT, &threads[i], test, args[i]) == 0,
            "Could not create thread %i\n", i+1
        );
    }

    for (int i = 0; i < n; i++) {
        fp_thread_join(threads[i], NULL);
    }

    free(threads);
}

void *trigger_du_same_time(void *args) {
    /**
     * Check that we can trigger two or more delay until instructions at the exact
     * same time without causing any bugs. This requires that they both use an
     * absolute time, which is passed through the argument.
     * 
     */
    uint32_t trigger_time = *((uint32_t*) (args));

    fp_delay_until(trigger_time);

    volatile uint32_t now = rdtime();
    fp_assert(trigger_time < now, 
        "delay until triggered at same time instant as another thread failed\n");
    return NULL;
}

void *trigger_wu_same_time(void *args) {
    /**
     * Check that we can trigger two or more delay until instructions at the exact
     * same time without causing any bugs. This requires that they both use an
     * absolute time, which is passed through the argument.
     * 
     */
    uint32_t trigger_time = *((uint32_t*) (args));

    fp_wait_until(trigger_time);

    volatile uint32_t now = rdtime();
    fp_assert(trigger_time < now, 
        "delay until triggered at same time instant as another thread failed\n");
    return NULL;
}

#define do_run(nthreads, test) do { \
    run_simultaneous_tests(nthreads, test, NULL); \
    printf(#test " passed for %i hw threads running simultaneously\n", nthreads); \
    reset_flags(); \
} while (0)

int main(void) {
    int nthreads = FP_THREADS-1;

    volatile uint32_t now = rdtime();

    // Set up absolute time for when the delay until instructions shall trigger
    // The trigger must be big enough that a single thread does not have time
    // to execute it before another thread is allocated the next. Otherwise
    // the same thread will simply run all triggers sequentually.
    uint32_t trigger = now + 1000000;
    uint32_t* triggers[FP_THREADS] = THREAD_ARRAY_INITIALIZER(&trigger);
    run_simultaneous_tests(nthreads, trigger_du_same_time, (void **) triggers);

    printf("trigger_du_same_time passed\n");

    // Set up the trigger variable again; it's pointer is read in the function
    // so we don't need to do much else
    now = rdtime();
    trigger = now + 10000;
    run_simultaneous_tests(nthreads, trigger_wu_same_time, (void **) triggers);

    printf("trigger_wu_same_time passed\n");
    
    do_run(nthreads, test_long_interrupt);
    do_run(nthreads, test_external_interrupt);
    do_run(nthreads, test_external_interrupt_disabled);
    do_run(nthreads, test_two_interrupts);
    do_run(nthreads, test_two_interrupts);
    do_run(nthreads, test_disabled_interrupts);
    do_run(nthreads, test_low_timeout);
    do_run(nthreads, test_fp_delay_until);
    do_run(nthreads, test_fp_wait_until);
}
