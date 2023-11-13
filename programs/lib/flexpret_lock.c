#include "flexpret.h"

/**
 * Acquire a hardware lock.
 */
void fp_hwlock_acquire(void) {
    while(swap_csr(CSR_HWLOCK, 1) == 0);
}

/**
 * Release a hardware lock.
 */
void fp_hwlock_release(void) {
    if (swap_csr(CSR_HWLOCK, 0) != 1) {
        fp_assert(false, "Attempt to unlock hwlock but it was not locked");
    };
}

static int do_acquire(fp_lock_t* lock) {
    fp_hwlock_acquire();
    if (lock->locked) {
        //printf("warn: attempt acquire locked lock\n");
        fp_hwlock_release();
        return 1;
    }
    lock->locked = true;
    lock->owner  = read_hartid();
    fp_hwlock_release();
    return 0;
}

void fp_lock_acquire(fp_lock_t* lock) {
    // Spin lock
    while(do_acquire(lock));
}

void fp_lock_release(fp_lock_t* lock) {
    fp_hwlock_acquire();
    fp_assert(read_hartid() == lock->owner, 
        "Attempt to release lock not owned by thread. thread id: %i, lock->owner: %i\n", 
        read_hartid(), lock->owner);
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    fp_hwlock_release();
}
