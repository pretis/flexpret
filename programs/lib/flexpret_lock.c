#include <flexpret_lock.h>
#include <flexpret_assert.h>

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
    assert(read_hartid() == lock->owner);
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    hwlock_release();
}
