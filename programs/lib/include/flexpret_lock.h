#include <stdbool.h>
#include <flexpret_csrs.h>
#include <flexpret_io.h>

#ifndef FLEXPRET_LOCK_H
#define FLEXPRET_LOCK_H

#define LOCK_INITIALIZER { .locked = false, .owner = UINT32_MAX }
typedef struct _lock_t {
    bool locked;
    uint32_t owner;
} lock_t;

/**
 * Acquire a hardware lock.
 */
static inline void hwlock_acquire() {
    while(swap_csr(CSR_HWLOCK, 1) == 0) {}
}

/**
 * Release a hardware lock.
 */
static inline void hwlock_release() {
    if (swap_csr(CSR_HWLOCK, 0) != 1) {
        _fp_print(666); // FIXME: Replace this with an assert().
        _fp_finish();
    };
}

/**
 * Software lock function declarations
 * 
 * @param lock the software lock instance to acquire/release
 */
void lock_acquire(lock_t* lock);
void lock_release(lock_t* lock);

#endif // FLEXPRET_LOCK_H
