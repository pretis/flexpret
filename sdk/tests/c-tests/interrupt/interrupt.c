#include <flexpret/flexpret.h>
#include <errno.h>
#include <string.h>

#include "interrupt.h"

// An interrupt will take time proportional to the number of threads
// because more threads -> more wasted cycles in the pipeline
// (At least when the hw threads are not sleeping, which is the case
//  at the time of writing this test.)
#define EXPIRE_DELAY_NS (((uint32_t)(1e4)) * (FP_THREADS))
#define TIMEOUT_INIT (1000)

static volatile int flag0[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int flag1[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int ext_int_flag[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int du_int_triggered[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int wu_int_triggered[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile uint64_t isr_time[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static volatile int ninterrupts[FP_THREADS] = THREAD_ARRAY_INITIALIZER(0);

void reset_flags(void) {
    memset((void *) flag0, 0, sizeof(flag0));
    memset((void *) flag1, 0, sizeof(flag1));
    memset((void *) ext_int_flag, 0, sizeof(ext_int_flag));
    memset((void *) du_int_triggered, 0, sizeof(du_int_triggered));
    memset((void *) wu_int_triggered, 0, sizeof(wu_int_triggered));
    memset((void *) isr_time, 0, sizeof(isr_time));
    memset((void *) ninterrupts, 0, sizeof(ninterrupts));
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

void ie_long(void) {
    int hartid = read_hartid();
    ninterrupts[hartid]++;
}

void *test_long_interrupt(void *args) {
    (void)(args);
    int hartid = read_hartid();

    volatile uint32_t before, now, expire;
    register_isr(EXC_CAUSE_EXTERNAL_INT, ie_long);

    before = rdtime();
    expire = before + 1000 * EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, ie_jumpto0);

    fp_interrupt_enable();
// Jumps here after interrupt
ie_jumpto0:
    while (ninterrupts[hartid] < 3);
    fp_interrupt_disable();

    now = rdtime();
    fp_assert(now < expire, "Interrupts did not occur in time\n");
    fp_assert(ninterrupts[hartid] >= 3, 
        "Long interrupt did not trigger interrupt handler enough\n");
    return NULL;
}

void *test_two_interrupts(void *args) {
    (void)(args);
    int hartid = read_hartid();

    volatile uint32_t before, now, expire;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    before = rdtime();
    expire = before + EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, ie_jumpto0);

    fp_interrupt_enable();
// Jumps here after interrupt
ie_jumpto0:
    while (flag0[hartid] == 0);
    fp_interrupt_disable();

    now = rdtime();
    fp_assert(now > expire, "Time is not as expected (condition was %li > %li)\n",
        now, expire);

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, ie_jumpto1);

    fp_interrupt_enable();
// Jumps here after interrupt
ie_jumpto1:
    while (flag1[hartid] == 0);
    fp_interrupt_disable();

    now = rdtime();
    fp_assert(now > expire, "Time is not as expected\n");

    // If context switch is not properly implemented, expect crash when returning
    // from this function because the return address (ra) register has not been
    // restored.
    return NULL;
}

void *test_disabled_interrupts(void *args) {
    (void)(args);
    int hartid = read_hartid();

    uint32_t timeout;
    volatile uint32_t now, expire;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, ie_occurred);

    timeout = TIMEOUT_INIT;
    // Do not enable interrupts
    while (flag0[hartid] == 0 && timeout--);

    fp_assert(flag0[hartid] == 0, "Interrupt occurred when disabled\n");

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, ie_occurred);

    timeout = TIMEOUT_INIT;
    // Do not enable interrupts
    while (flag1[hartid] == 0 && timeout--);

    fp_assert(flag1[hartid] == 0, "Interrupt occurred when disabled\n");

    return NULL;

ie_occurred:
    fp_assert(0, "Interrupt on expire expired\n");
    return NULL;
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
     * be expired by the time the fp_int_on_expire() function is called.
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
    fp_int_on_expire(expire, ie_jumpto);
    fp_interrupt_enable();
ie_jumpto:
    while (flag0[hartid] == 0);
    fp_interrupt_disable();
    return NULL;
}

void *test_interrupt_expire_with_expire(void *args) {
    (void)(args);
    volatile uint32_t now, expire, while_until;

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    while_until = expire + EXPIRE_DELAY_NS;
    fp_int_on_expire(expire, cleanup);
    fp_interrupt_enable();

    // Busy poll longer than interrupt on expire
    while (rdtime() < while_until);
    fp_assert(0, "Interrupt on expire did not run cleanup when expired\n");

cleanup:
    return NULL;
}

void *test_exception_expire_with_expire(void *args) {
    (void)(args);
    volatile uint32_t now, expire, while_until;

    register_isr(EXC_CAUSE_EXCEPTION_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + EXPIRE_DELAY_NS;
    while_until = expire + EXPIRE_DELAY_NS;
    fp_exc_on_expire(expire, cleanup);
    fp_interrupt_enable();

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

    fp_int_on_expire(expire, ie_jumpto);
    fp_interrupt_enable();
ie_jumpto:
    fp_delay_until(delay);
    fp_interrupt_disable();

    now = rdtime();

    fp_assert(isr_time[hartid] != 0, "Interrupt did not occur\n");
    fp_assert(now > delay, "Delay until did not delay full duration\n");
    fp_assert(expire < isr_time[hartid] && isr_time[hartid] < delay, "Interrupt did not occur during delay until\n");

    now = rdtime();

    // Try to delay for an absolute time less than the current time and check that
    // we just fall through. A buggy implementation might yield an infinite loop.
    // Assume executing these instructions take less than 1 us
    fp_delay_until(now);

    volatile uint32_t after = rdtime();
    fp_assert(now < after && after < (now + (int) (1e3)),
        "Delay until ran at absolute time less than current time took longer time then expected\n");
    return NULL;
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

    fp_int_on_expire(expire, ie_jumpto);
    fp_interrupt_enable();
    fp_wait_until(delay);
ie_jumpto:
    fp_interrupt_disable();

    now = rdtime();

    fp_assert(isr_time[hartid] != 0, "Interrupt did not occur\n");
    fp_assert(expire < now && now < delay, "Time not as expected\n");
    fp_assert(before < isr_time[hartid] && 
              expire < isr_time[hartid] && 
              isr_time[hartid] < now && 
              isr_time[hartid] < delay, 
              "Interrupt did not occur when expected\n"
    );

    now = rdtime();

    // Try to wait for an absolute time less than the current time and check that
    // we just fall through. A buggy implementation might yield an infinite loop.
    // Assume executing these instructions take less than 1 us
    fp_wait_until(now);

    volatile uint32_t after = rdtime();
    fp_assert(now < after && after < (now + (int) (1e3)),
        "Wait until ran at absolute time less than current time took longer time then expected\n");
    return NULL;
}

void *test_external_interrupt(void *args) {
    (void) (args);
    int hartid = read_hartid();

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_isr);
    fp_interrupt_enable();
    while (ext_int_flag[hartid] == 0);
    fp_interrupt_disable();
    return NULL;
}

void *test_external_interrupt_disabled(void *args) {
    (void) (args);
    int hartid = read_hartid();

    uint32_t timeout = 100*TIMEOUT_INIT;

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_isr);
    
    // Do not enable interrupts and wait so there is time for an interrupt signal
    // to come
    while (ext_int_flag[hartid] == 0 && timeout--);

    fp_assert(ext_int_flag[hartid] == 0, 
        "External interrupt was triggered when disabled\n");
    return NULL;
}

void *test_du_not_stopped_by_int(void *args) {
    (void) (args);
    int hartid = read_hartid();

    register_isr(EXC_CAUSE_EXTERNAL_INT, ext_int_du_response);
    volatile uint64_t before, delay, after;
    
    before = rdtime64();
    delay = (int) 10000000;
    
    fp_interrupt_enable();
    fp_delay_for(delay);
    fp_interrupt_disable();
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
    
    fp_interrupt_enable();
    fp_wait_for(delay);
    fp_interrupt_disable();
    after = rdtime64();

    if (wu_int_triggered[hartid]) {
        fp_assert(before + delay > after, "User was unable to stop wait until instruction before timer had run out\n");
        return NULL;
    } else {
        printf("Warning: User should provide interrupt to test this feature\n");
        return (void *) 1;
    }
}
