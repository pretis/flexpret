#include <flexpret.h>
#include <errno.h>
#include <string.h>

#include "interrupt.h"

// An interrupt will take time proportional to the number of threads
// because more threads -> more wasted cycles in the pipeline
// (At least when the hw threads are not sleeping, which is the case
//  at the time of writing this test.)
#define EXPIRE_DELAY_NS (((uint32_t)(1e6)) * (NUM_THREADS))
#define TIMEOUT_INIT (10000)

static volatile int flag0[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int flag1[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int ext_int_flag[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int du_int_triggered[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int wu_int_triggered[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile uint64_t isr_time[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);

void reset_flags(void) {
    memset((void *) flag0, 0, sizeof(flag0));
    memset((void *) flag1, 0, sizeof(flag1));
    memset((void *) ext_int_flag, 0, sizeof(ext_int_flag));
    memset((void *) du_int_triggered, 0, sizeof(du_int_triggered));
    memset((void *) wu_int_triggered, 0, sizeof(wu_int_triggered));
}

void ie_isr0(void) {
    int hartid = read_hartid();
    flag0[hartid] = 1;
}

void ie_isr1(void) {
    int hartid = read_hartid();
    flag1[hartid] = 1;
}

void ext_int_isr(void) {
    int hartid = read_hartid();
    ext_int_flag[hartid] = 1;
}

void ext_int_du_response(void) {
    printf("Got interrupt while in delay until (should not be early stopped by interrupt)\n");
    int hartid = read_hartid();
    du_int_triggered[hartid] = 1;
}

void ext_int_wu_response(void) {
    printf("Got interrupt while in wait until (should be stopped early by interrupt)\n");
    int hartid = read_hartid();
    wu_int_triggered[hartid] = 1;
}

void ie_isr_get_time(void) {
    int hartid = read_hartid();
    isr_time[hartid] = rdtime64();
}

void *test_two_interrupts(void *args) {
    (void)(args);
    int hartid = read_hartid();

    volatile uint32_t before, now, expire;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    before = rdtime();
    expire = before + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire, ie_jumpto0);

    ENABLE_INTERRUPTS();
// Jumps here after interrupt
ie_jumpto0:
    while (flag0[hartid] == 0);
    DISABLE_INTERRUPTS();

    now = rdtime();
    fp_assert(now > expire, "Time is not as expected (condition was %i > %i)\n",
        now, expire);

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire, ie_jumpto1);

    ENABLE_INTERRUPTS();
// Jumps here after interrupt
ie_jumpto1:
    while (flag1[hartid] == 0);
    DISABLE_INTERRUPTS();

    now = rdtime();
    fp_assert(now > expire, "Time is not as expected\n");

    // If context switch is not properly implemented, expect crash when returning
    // from this function because the return address (ra) register has not been
    // restored.
}

void *test_disabled_interrupts(void *args) {
    (void)(args);
    int hartid = read_hartid();

    uint32_t timeout;
    volatile uint32_t now, expire;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire, ie_occurred);

    timeout = TIMEOUT_INIT;
    // Do not enable interrupts
    while (flag0[hartid] == 0 && timeout--);

    fp_assert(flag0[hartid] == 0, "Interrupt occurred when disabled\n");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire, ie_occurred);

    timeout = TIMEOUT_INIT;
    // Do not enable interrupts
    while (flag1[hartid] == 0 && timeout--);

    fp_assert(flag1[hartid] == 0, "Interrupt occurred when disabled\n");

    return NULL;

ie_occurred:
    fp_assert(0, "Interrupt on expire expired\n");
}

void *test_low_timeout(void *args) {
    (void) (args);
    int hartid = read_hartid();

    volatile uint32_t now, expire;

    // Feel free to play around with this value and see what happens
    const uint32_t timeout_ns = 10000;

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
    INTERRUPT_ON_EXPIRE(expire, ie_jumpto);
    ENABLE_INTERRUPTS();
ie_jumpto:
    while (flag0[hartid] == 0);
    DISABLE_INTERRUPTS();
}

void *test_interrupt_expire_with_expire(void *args) {
    (void)(args);
    int hartid = read_hartid();

    uint32_t timeout;
    volatile uint32_t now, expire, while_until;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    while_until = expire + EXPIRE_DELAY_NS;
    INTERRUPT_ON_EXPIRE(expire, cleanup);
    ENABLE_INTERRUPTS();

    // Busy poll longer than interrupt on expire
    while (rdtime() < while_until);
    fp_assert(0, "Interrupt on expire did not run cleanup when expired\n");

cleanup:
    return NULL;
}

void *test_exception_expire_with_expire(void *args) {
    (void)(args);
    int hartid = read_hartid();

    uint32_t timeout;
    volatile uint32_t now, expire, while_until;

    register_isr(EXC_CAUSE_EXCEPTION_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    while_until = expire + EXPIRE_DELAY_NS;
    EXCEPTION_ON_EXPIRE(expire, cleanup);
    ENABLE_INTERRUPTS();

    // Busy poll longer than exception on expire
    while (rdtime() < while_until);
    fp_assert(0, "Exception on expire did not run cleanup when expired\n");

cleanup:
    return NULL;
}

void *test_fp_delay_until(void *args) {
    (void)(args);
    int hartid = read_hartid();

    // Delay until should execute all interrupts but keep sleeping until the
    // specified timeout has occurred
    volatile uint32_t now, expire, delay;
    const uint32_t timeout_ns = EXPIRE_DELAY_NS;

    isr_time[hartid] = 0;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr_get_time);

    now = rdtime();
    expire = now + timeout_ns;
    delay = expire + timeout_ns;

    INTERRUPT_ON_EXPIRE(expire, ie_jumpto);
    ENABLE_INTERRUPTS();
ie_jumpto:
    fp_delay_until(delay);
    DISABLE_INTERRUPTS();

    now = rdtime();

    fp_assert(isr_time[hartid] != 0, "Interrupt did not occur\n");
    fp_assert(now > delay, "Delay until did not delay full duration\n");
    fp_assert(expire < isr_time[hartid] && isr_time[hartid] < delay, "Interrupt did not occur during delay until\n");
}

void *test_fp_wait_until(void *args) {
    (void) (args);
    int hartid = read_hartid();

    // Wait until should sleep until an interrupt occurs or the timeout value is
    // reached. If an interrupt occurs, it should execute it and continue
    // execution (i.e., stop sleeping).
    volatile uint32_t before, now, expire, delay;
    const uint32_t timeout_ns = EXPIRE_DELAY_NS;

    isr_time[hartid] = 0;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr_get_time);
    
    before = rdtime();
    expire = before + timeout_ns;
    delay = expire + timeout_ns;

    INTERRUPT_ON_EXPIRE(expire, ie_jumpto);
    ENABLE_INTERRUPTS();
    fp_wait_until(delay);
ie_jumpto:
    DISABLE_INTERRUPTS();

    now = rdtime();

    fp_assert(isr_time[hartid] != 0, "Interrupt did not occur\n");
    fp_assert(expire < now && now < delay, "Time not as expected: expire: %i, now: %i, delay: %i\n",
        expire, now, delay);
    fp_assert(before < isr_time[hartid] && 
              expire < isr_time[hartid] && 
              isr_time[hartid] < now && 
              isr_time[hartid] < delay, 
              "Interrupt did not occur when expected\n"
    );
}

void *test_external_interrupt(void *args) {
    (void) (args);
    int hartid = read_hartid();

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_isr);
    ENABLE_INTERRUPTS();
    while (ext_int_flag[hartid] == 0);
    DISABLE_INTERRUPTS();
}

void *test_du_not_stopped_by_int(void *args) {
    (void) (args);
    int hartid = read_hartid();

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_du_response);
    volatile uint64_t before, delay, after;
    
    before = rdtime64();
    delay = (int) 10000000;
    
    ENABLE_INTERRUPTS();
    fp_delay_for(delay);
    DISABLE_INTERRUPTS();
    after = rdtime64();

    if (du_int_triggered[hartid]) {
        fp_assert(before + delay < after, "User was able to stop delay until instruction before timer had run out");
        return NULL;
    } else {
        printf("Warning: User should provide interrupt to test this feature\n");
        return (void *) 1;
    }
}

void *test_wu_stopped_by_int(void *args) {
    (void) (args);
    int hartid = read_hartid();

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_wu_response);
    volatile uint64_t before, delay, after;

    before = rdtime64();
    delay = (int) 10000000;
    
    ENABLE_INTERRUPTS();
    fp_wait_for(delay);
    DISABLE_INTERRUPTS();
    after = rdtime64();

    if (wu_int_triggered[hartid]) {
        fp_assert(before + delay > after, "User was unable to stop wait until instruction before timer had run out\n");
        return NULL;
    } else {
        printf("Warning: User should provide interrupt to test this feature\n");
        return (void *) 1;
    }
}
