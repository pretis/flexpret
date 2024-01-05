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
    // Do recursive lock
    if (lock->owner == read_hartid()) {
        lock->count++;
        return 0;
    }
    // Spin polling the software lock, without trying to acquire the hwlock
    while (lock->owner >= 0) {}
    
    // At this point, we can grab the hwlock
    fp_hwlock_acquire();
    
    // Check if someone else got it before us.
    if (lock->owner >= 0) {
        fp_hwlock_release();
        return 1;
    } else {
        lock->owner  = read_hartid();
        lock->count = 1;
        fp_hwlock_release();
        return 0;
    }
}

void fp_lock_acquire(fp_lock_t* lock) {
    // Spin lock
    while(do_acquire(lock));
}

void fp_lock_release(fp_lock_t* lock) {
    fp_assert(read_hartid() == lock->owner, 
        "Attempt to release lock not owned by thread. thread id: %i, lock->owner: %i\n", 
        read_hartid(), lock->owner);
    fp_assert(lock->count > 0, 
        "Attempt to relase lock with count <= 0: count: %i\n", lock->count);
    fp_hwlock_acquire();
    if (--lock->count == 0) {
        lock->owner  = -1;
    }
    fp_hwlock_release();
}
