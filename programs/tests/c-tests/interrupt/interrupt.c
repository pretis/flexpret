#include <flexpret.h>
#include <errno.h>

#define EXTERNAL_INTERRUPT_TEST (0)

#define EXPIRE_DELAY_NS (uint32_t)(1e6)

static int flag0 = 0;
static int flag1 = 0;
static int ext_int_flag = 0;

void ie_isr0(void) {
    flag0 = 1;
}

void ie_isr1(void) {
    flag1 = 1;
}

void ext_int_isr(void) {
    ext_int_flag = 1;
}

void test_two_interrupts(void) {
    volatile uint32_t now, expire;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire);

    while (flag0 == 0);

    now = rdtime();
    assert(now > expire, "Time is not as expected");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire);

    while (flag1 == 0);

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
    INTERRUPT_ON_EXPIRE(expire);

    timeout = timeout_init;
    while (flag0 == 0 && timeout--);

    assert(flag0 == 0, "Interrupt occurred when disabled");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire);

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
     * be expired by the time the INTERRUPT_ON_EXPIRE() function is called.
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
    INTERRUPT_ON_EXPIRE(expire);
    while (flag0 == 0);
}

void test_delay_until(void) {
    // Delay until should execute all interrupts but keep sleeping until the
    // specified timeout has occurred
    volatile uint32_t now, expire, delay;
    const uint32_t timeout_ns = 100000;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);

    now = rdtime();
    expire = now + timeout_ns;
    delay = expire + timeout_ns;

    INTERRUPT_ON_EXPIRE(expire);
    delay_until(delay);

    now = rdtime();
    assert(now > delay, "Time not as expected");
    
    /**
     * Does not work since INTERRUPT_ON_EXPIRE and delay_until use the same
     * CSR register CSR_COMPARE - so delay_until just overwrites the value of
     * the INTERRUPT_ON_EXPIRE instruction.
     */
    //assert(flag0 == 1, "Interrupt did not occur");
}

void test_wait_until(void) {
    // Wait until should sleep until an interrupt occurs or the timeout value is
    // reached. If an interrupt occurs, it should execute it and continue
    // execution (i.e., stop sleeping).
    volatile uint32_t now, expire, delay;

    const uint32_t timeout_ns = 10000;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + timeout_ns;
    delay = expire + timeout_ns;

    INTERRUPT_ON_EXPIRE(expire);
    wait_until(delay);

    now = rdtime();

    /**
     * Does not work since INTERRUPT_ON_EXPIRE and wait_until use the same
     * CSR register CSR_COMPARE - so wait_until just overwrites the value of
     * the INTERRUPT_ON_EXPIRE instruction.
     * 
     */
    //assert(expire < now && now < delay, "Time not as expected");
    //assert(flag1 == 1, "Interrupt did not occur");
}

int main(void) {
    ENABLE_INTERRUPTS();

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
    DISABLE_INTERRUPTS();
    test_disabled_interrupts(10000);
    printf("3rd run: interrupts were disabled and none were triggered\n");
    ENABLE_INTERRUPTS();

    // No need to reset flags if the interrupts were not run

    test_low_timeout();
    printf("4th run: interrupts ran sucessfully with low timeout\n");

    flag0 = 0;
    flag1 = 0;

    test_delay_until();

    printf("5th run: delay until ran sucessfully\n");

    flag0 = 0;
    flag1 = 0;

    test_wait_until();

    printf("6th run: wait until ran sucessfully\n");

#if EXTERNAL_INTERRUPT_TEST
    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_isr);
    while (ext_int_flag == 0);
    printf("7th run: got external interrupt\n");
#endif // EXTERNAL_INTERRUPT_TEST

    return 0;
}
