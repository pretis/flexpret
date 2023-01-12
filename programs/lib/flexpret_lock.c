#include <flexpret_lock.h>

int do_acquire(lock_t* lock) {
    if (lock->locked == true)
        return 0;
    hwlock_acquire();
    lock->locked = true;
    lock->owner  = read_hartid();
    hwlock_release();
    return 1;
}

void lock_acquire(lock_t* lock) {
    // Spin lock
    while(do_acquire(lock) == 0) {}
}

void lock_release(lock_t* lock) {
    if (read_hartid() != lock->owner) {
        _fp_print(6661); // FIXME: Replace this with an assert.
        return;
    }
    hwlock_acquire();
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    hwlock_release();
}
