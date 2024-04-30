#include <flexpret/flexpret.h>
#include "interrupt.h"

#define do_run(test) do { \
    test(NULL); \
    printf(#test " ran sucessfully\n"); \
    reset_flags(); \
} while(0)

int main(void) {
    do_run(test_long_interrupt);
    do_run(test_two_interrupts);
    do_run(test_two_interrupts);
    do_run(test_disabled_interrupts);
    do_run(test_low_timeout);
    do_run(test_fp_delay_until);
    do_run(test_fp_wait_until);
    do_run(test_external_interrupt);
    do_run(test_external_interrupt_disabled);

    if (!test_du_not_stopped_by_int(NULL)) {
        printf("delay for not stopped early (as expected)\n");
    }

    reset_flags();

    if (!test_wu_stopped_by_int(NULL)) {
        printf("wait for stopped early (as expected)\n");
    }

    reset_flags();

    return 0;
}
