#ifndef FLEXPRET_LOCK_H
#define FLEXPRET_LOCK_H

#include <stdbool.h>
#include <stdint.h>

#define LOCK_INITIALIZER { .locked = false, .owner = UINT32_MAX, .first_waiter = 0, .has_first_waiter = false }
typedef struct _lock_t {
    bool     locked;
    uint32_t owner;
    bool has_first_waiter;
    uint32_t first_waiter;
} lock_t;

/**
 * Acquire a hardware lock.
 */
void hwlock_acquire();

/**
 * Release a hardware lock.
 */
void hwlock_release();

/**
 * Software lock function declarations
 * 
 * @param lock the software lock instance to acquire/release
 */
void lock_acquire(lock_t* lock);
void lock_release(lock_t* lock);

#endif // FLEXPRET_LOCK_H
