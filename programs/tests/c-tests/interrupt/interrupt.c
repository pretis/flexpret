#include <flexpret.h>
#include <errno.h>

#define EXPIRE_DELAY_NS (uint32_t)(1e6)

static int flag0 = 0;
static int flag1 = 0;

void ie_isr0(void) {
    flag0 = 1;
}

void ie_isr1(void) {
    flag1 = 1;
}

void test_two_interrupts(void) {
    volatile uint32_t now, expire;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    interrupt_on_expire(expire);

    enable_interrupts();
    while (flag0 == 0);
    disable_interrupts();

    now = rdtime();
    assert(now > expire, "Time is not as expected");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    interrupt_on_expire(expire);

    enable_interrupts();
    while (flag1 == 0);
    disable_interrupts();

    now = rdtime();
    assert(now > expire, "Time is not as expected");

    // If context switch is not properly implemented, expect crash when returning
    // from this function because the return address (ra) register has not been
    // restored.
}

void test_disabled_interrupts(const uint32_t timeout_init) {
    uint32_t timeout;
    volatile uint32_t now, expire;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    interrupt_on_expire(expire);

    timeout = timeout_init;
    while (flag0 == 0 && timeout--);

    assert(flag0 == 0, "Interrupt occurred when disabled");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    interrupt_on_expire(expire);

    timeout = timeout_init;
    while (flag1 == 0 && timeout--);

    assert(flag1 == 0, "Interrupt occurred when disabled");
}

void test_low_timeout(void) {
    volatile uint32_t now, expire;

    // Feel free to play around with this value and see what happens
    const uint32_t timeout_ns = 2000;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + timeout_ns;

    /**
     * The problem with using such a low value for expire is that it will already
     * be expired by the time the interrupt_on_expire() function is called.
     * I.e., the exception will trigger right after the CSR_COMPARE register has
     * been written (see the function implementation). Then the second inline
     * assembly will not be executed before the exception occurs. This also 
     * breaks the stack pointer, because the two instructions below do not get 
     * executed.
     * 
     * With the macro DEBUG = 1, the invalid user input is handled by the function
     * and the interrupt is not run. Without DEBUG = 1, the stack pointer
     * is broken and a crash is likely to occur.
     * 
     */
    enable_interrupts();
    interrupt_on_expire(expire);
    disable_interrupts();
    while (flag0 == 0);
}

int main(void) {    
    // Test that interrupts work
    test_two_interrupts();
    printf("1st run: interrupts ran sucessfully with two different ISRs\n");

    flag0 = 0;
    flag1 = 0;

    // Test that they work again; i.e., there are no side effects of the first
    // test
    test_two_interrupts();
    printf("2nd run: interrupts ran sucessfully with two different ISRs\n");

    flag0 = 0;
    flag1 = 0;

    // Try to disable interrupts and check that no interrupts were called
    test_disabled_interrupts(100000);
    printf("3rd run: interrupts were disabled and none were triggered\n");

    // No need to reset flags if the interrupts were not run

    test_low_timeout();
    printf("4th run: interrupts ran sucessfully with low timeout\n");

    return 0;
}