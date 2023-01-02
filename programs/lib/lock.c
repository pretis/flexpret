#include <flexpret_lock.h>

int do_acquire(lock_t* lock) {
    hwlock_acquire();
    if (*lock == true)
        return 0;
    else *lock = true;
    hwlock_release();
    return 1;
}

void lock_acquire(lock_t* lock) {
    while(do_acquire(lock) == 0) {}
}

void lock_release(lock_t* lock) {
    hwlock_acquire();
    *lock = false;
    hwlock_release();
}