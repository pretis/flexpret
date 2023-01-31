#include <flexpret_lock.h>
#include <flexpret_assert.h>

int do_acquire(lock_t* lock) {
    int res;
    if (lock->locked == true) {
        res = 0;
    } else {
        hwlock_acquire();
        if (lock->locked == true) {
            res = 0;
        } else {
            lock->locked = true;
            lock->owner  = read_hartid();
            res = 1;
        }
        hwlock_release();
    }
    return res;
}

void lock_acquire(lock_t* lock) {
    // Spin lock
    while(do_acquire(lock) == 0) {}
}

void lock_release(lock_t* lock) {
    _fp_print(2222);
    _fp_print(read_hartid());
    assert(read_hartid() == lock->owner);
    hwlock_acquire();
    lock->locked = false;
    lock->owner  = UINT32_MAX;
    hwlock_release();
}
