#include <flexpret.h>

static_assert(NUM_THREADS >= 4);
#define USED_THREADS 4

static int flags[NUM_THREADS] = THREAD_ARRAY_INITIALIZER(0);
static lock_t interrupt_lock = LOCK_INITIALIZER;

void ie_isr0(void) {
    flags[0] = 1;
}

void ie_isr1(void) {
    flags[1] = 1;
}

void ie_isr2(void) {
    flags[2] = 1;
}

void ie_isr3(void) {
    flags[3] = 1;
}

void *single_thread(void *arg) {
    enable_interrupts();

    uint32_t now, expire;
    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr0);
    
    now = rdtime();
    expire = now + 1000000;
    interrupt_on_expire(expire);

    while (flags[0] == 0);

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, ie_isr1);
    
    now = rdtime();
    expire = now + 100000;
    interrupt_on_expire(expire);

    while (flags[1] == 0);

    disable_interrupts();

    return 0;

    // If context switch is not properly implemented, expect crash when returning
    // from this function because the return address (ra) register has not been
    // restored.
}

static void register_isr_tid(int tid) {
    void (*isr)(void);
    
    switch (tid)
    {
    case 1:
        isr = ie_isr1; break;
    case 2:
        isr = ie_isr2; break;
    case 3:
        isr = ie_isr3; break;
    default:
        isr = NULL; break;
    }

    register_isr(EXC_CAUSE_INTERRUPT_EXPIRE, isr);
}

void *worker(void *arg) {
    int tid = read_hartid();
    uint32_t now, expire;

    lock_acquire(&interrupt_lock);
    register_isr_tid(tid);

    now = rdtime();
    expire = now + tid * 100000;
    interrupt_on_expire(expire);

    enable_interrupts();
    while (flags[tid] == 0);
    disable_interrupts();

    lock_release(&interrupt_lock);
}

int main() {
    // Run the single thread test with thread 0 (main)
    single_thread(NULL);

    printf("1st run: single thread from main success\n");

    flags[0] = 0;
    flags[1] = 0;

    // Run the single thread test with another thread
    thread_t another_thread;
    assert(thread_create(HRTT, &another_thread, single_thread, NULL) == 0,
        "Could not create thread");
    
    thread_join(another_thread, NULL);
    printf("2nd run: single thread from different thread success\n");

    flags[0] = 0;
    flags[1] = 0;

    // Run multiple tests simultaneously
    thread_t tid[USED_THREADS-1];
    for (int i = 0; i < USED_THREADS-1; i++) {
        assert(thread_create(HRTT, &tid[i], worker, NULL) == 0,
            "Could not create thread");
    }

    for (int i = 0; i < USED_THREADS-1; i++) {
        thread_join(tid[i], NULL);
    }

    printf("3rd run: %i threads all ran one interrupt each\n", USED_THREADS-1);

    return 0;
}