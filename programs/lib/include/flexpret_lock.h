#ifndef FLEXPRET_LOCK_H
#define FLEXPRET_LOCK_H

#include <stdbool.h>
#include <stdint.h>

#define FP_LOCK_INITIALIZER {.owner = -1, .count = 0 }
typedef struct {
    int owner; // -1 means it is unlocked.
    uint32_t count;
} fp_lock_t;

/**
 * Acquire a hardware lock.
 */
void fp_hwlock_acquire(void);

/**
 * Release a hardware lock.
 */
void fp_hwlock_release(void);

/**
 * Software lock function declarations
 * 
 * @param lock the software lock instance to acquire/release
 */
void fp_lock_acquire(fp_lock_t* lock);
void fp_lock_release(fp_lock_t* lock);

#endif // FLEXPRET_LOCK_H
