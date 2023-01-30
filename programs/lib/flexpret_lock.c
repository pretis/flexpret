#include <flexpret_lock.h>

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
