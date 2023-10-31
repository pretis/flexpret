#include "flexpret.h"

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
        fp_assert(false, "Attempt to unlock hwlock but it was not locked");
    };
}

int do_acquire(lock_t* lock) {
    hwlock_acquire();
    if (lock->locked) {
        hwlock_release();
        return 1;
    }
    lock->locked = true;
    lock->owner  = read_hartid();
    hwlock_release();
    return 0;
}

void lock_acquire(lock_t* lock) {
    // Spin lock
    while(do_acquire(lock));
}

void lock_release(lock_t* lock) {
    hwlock_acquire();
    fp_assert(read_hartid() == lock->owner, "Attempt to release lock not owned by thread");
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    hwlock_release();
}
