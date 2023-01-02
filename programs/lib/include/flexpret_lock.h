#include <stdbool.h>
#include <flexpret_csrs.h>
#include <flexpret_io.h>

#ifndef FLEXPRET_LOCK_H
#define FLEXPRET_LOCK_H

static inline void hwlock_acquire() {
    while(swap_csr(CSR_HWLOCK, 1) == 0) {}
}

static inline void hwlock_release() {
    if (swap_csr(CSR_HWLOCK, 0) != 1) {
        _fp_print(666);
        _fp_finish();
    };
}

#define LOCK_INITIALIZER false

typedef bool lock_t;

void lock_acquire(lock_t* lock);
void lock_release(lock_t* lock);

#endif // FLEXPRET_LOCK_H