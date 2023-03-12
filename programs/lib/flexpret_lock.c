
#include "flexpret_lock.h"
#include "flexpret_csrs.h"
#include "flexpret_io.h"

#include <stdint.h>

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
    uint32_t hartid = read_hartid();
    if (hartid != lock->owner) {
        // FIXME: Replace this with an assert.
        _fp_print(6661);
        hwlock_release();
        return;
    }
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    hwlock_release();
}
