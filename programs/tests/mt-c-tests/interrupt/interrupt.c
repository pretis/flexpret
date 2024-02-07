#include <flexpret.h>
#include <stdlib.h>
#include "../../c-tests/interrupt/interrupt.h"

void run_simultaneous_tests(const int n, void *(*test)(void *)) {
    fp_thread_t *threads = malloc(n * sizeof(fp_thread_t));
    fp_assert(threads, "Could not malloc threads\n");
    for (int i = 0; i < n; i++) {
        printf("Start %i\n", i);
        fp_assert(
            fp_thread_create(HRTT, &threads[i], test, NULL) == 0,
            "Could not create thread %i\n", i
        );
    }

    for (int i = 0; i < n; i++) {
        fp_thread_join(threads[i], NULL);
    }
}

int main(void) {
    run_simultaneous_tests(4, test_two_interrupts);

    printf("test_two_interrupts passed for %i hw threads running simultaneously\n");
}
