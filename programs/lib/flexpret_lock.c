#include "flexpret.h"


/*
linked list
*/
static bool has_next_waiter[NUM_THREADS];
static uint32_t next_waiter[NUM_THREADS];

/**
 * Acquire a hardware lock.
 */
void hwlock_acquire() {
    while(swap_csr(CSR_HWLOCK, 1) == 0);
}

/**
 * Release a hardware lock.
 */
void hwlock_release() {
    if (swap_csr(CSR_HWLOCK, 0) != 1) {
        _fp_print(666); // FIXME: Replace this with an assert().
        _fp_finish();
    };
}

int do_acquire(lock_t* lock) {
    uint32_t hartid = read_hartid();
    hwlock_acquire();
    if (lock->locked) {
        // append to front of lock's linked list
        has_next_waiter[hartid] = lock->has_first_waiter;
        next_waiter[hartid] = lock->first_waiter;
        lock->has_first_waiter = true;
        lock->first_waiter = hartid;
        hwlock_release();
        fp_sleep(); // sleep until lock is availible
        return 1;
    }
    lock->locked = true;
    lock->owner  = hartid;
    hwlock_release();
    return 0;
}

void lock_acquire(lock_t* lock) {
    while(do_acquire(lock));
}

void lock_release(lock_t* lock) {
    hwlock_acquire();
    uint32_t hartid = read_hartid();
    if (hartid != lock->owner) {
        // FIXME: Replace this with an assert.
        _fp_print(6661);
        hwlock_release();
        return;
    }
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    if (lock->has_first_waiter) {
        // pop first waiter off of linked list
        uint32_t fw = lock->first_waiter;
        lock->has_first_waiter = has_next_waiter[fw];
        lock->first_waiter = next_waiter[fw];
        // wake first waiter
        fp_wake(fw);
    }
    hwlock_release();
}
