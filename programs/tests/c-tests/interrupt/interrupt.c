#include <flexpret_io.h>
#include <flexpret_csrs.h>
#include <flexpret_exceptions.h>

int flag=0;

void ie_isr(void) {
    uint32_t now = rdtime();
    printf("num: %i\n", 42);
    printf("num: %i\n", now);
    flag=1;
}

int submain() {
    printf("num: %i\n", 1);

    enable_interrupts();
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr);
    uint32_t now = rdtime();
    uint32_t expire = now + 100000;
    printf("num: %i\n", expire);
    interrupt_on_expire(expire);

    while (flag==0) {}

    printf("Out of while\n");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, NULL);

    return 0;

    // If context switch is not properly implemented, expect crash when returning
    // from this function because the return address (ra) register has not been
    // restored.
}

int main() {
    int ret = submain();

    printf("submain ret: %i\n", ret);

    return ret;
}