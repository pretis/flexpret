#include <flexpret.h>
#include "interrupt.h"

int main(void) {
    // Test that interrupts work
    test_two_interrupts(NULL);
    printf("1st run: interrupts ran sucessfully with two different ISRs\n");

    reset_flags();

    // Test that they work again; i.e., there are no side effects of the first
    // test
    test_two_interrupts(NULL);
    printf("2nd run: interrupts ran sucessfully with two different ISRs\n");

    reset_flags();

    // Try to disable interrupts and check that no interrupts were called
    test_disabled_interrupts(NULL);
    printf("3rd run: interrupts were disabled and none were triggered\n");

    // No need to reset flags if the interrupts were not run

    test_low_timeout(NULL);
    printf("4th run: interrupts ran sucessfully with low timeout\n");

    reset_flags();

    test_fp_delay_until(NULL);
    printf("5th run: delay until ran sucessfully\n");

    reset_flags();

    test_fp_wait_until(NULL);
    printf("6th run: wait until ran sucessfully\n");

    reset_flags();

    test_external_interrupt(NULL);
    printf("7th run: got external interrupt\n");

    reset_flags();

    if (!test_du_not_stopped_by_int(NULL)) {
        printf("8th run: delay for not stopped early\n");
    }

    reset_flags();

    if (!test_wu_stopped_by_int(NULL)) {
        printf("9th run: wait for stopped early\n");
    }

    return 0;
}
