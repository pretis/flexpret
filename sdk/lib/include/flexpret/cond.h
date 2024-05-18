#ifndef FLEXPRET_COND_H
#define FLEXPRET_COND_H

#include <stdbool.h>
#include <stdint.h>

#include <flexpret/flexpret.h>

typedef struct {
    volatile bool waiting[FP_THREADS];
    fp_lock_t *lock;    
} fp_cond_t;
#define FP_COND_INITIALIZER(lock_ptr) { .waiting = THREAD_ARRAY_INITIALIZER(false), .lock = lock_ptr}

/**
 * @brief Wait on the condition variable. The lock associated with `cond` must be held
 * 
 * @param cond 
 * @return fp_ret_t 
 */
fp_ret_t fp_cond_wait(fp_cond_t * cond);

/**
 * @brief Wait on the condition variable with a timeout. Timeout is a 64 bit absolute timepoint given in nanosconds
 * 
 * @param cond 
 * @return fp_ret_t FP_SUCCESS or FP_TIMEOUT
 */
fp_ret_t fp_cond_timed_wait(fp_cond_t * cond, uint64_t timeout);

/**
 * @brief Signal a condition variable and wake up a waiting thread.
 * FIXME: There is no fairness implemented. The threads with lower hartid are prioritized
 * 
 * @param cond 
 * @return fp_ret_t 
 */
fp_ret_t fp_cond_signal(fp_cond_t * cond);

/**
 * @brief Signal all waiting threads
 * 
 * @param cond 
 * @return fp_ret_t 
 */
fp_ret_t fp_cond_broadcast(fp_cond_t * cond);

#endif