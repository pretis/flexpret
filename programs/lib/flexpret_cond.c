#include <flexpret.h>
#include "flexpret_cond.h"

fp_ret_t cond_wait(fp_cond_t * cond) {
    int hartid = read_hartid();
    cond->waiting[hartid] = true;
    lock_release(cond->lock);
    while(cond->waiting[hartid]) {}
    lock_acquire(cond->lock);
    return FP_SUCCESS;
}

fp_ret_t fp_cond_timed_wait(fp_cond_t * cond, uint64_t timeout) {
    bool has_timed_out = false;
    uint32_t now = rdtime();
    int hartid = read_hartid();
    cond->waiting[hartid] = true;
    lock_release(cond->lock);
    while(cond->waiting[hartid] && !has_timed_out) {
        has_timed_out = (rdtime64() >= timeout);
    }
    lock_acquire(cond->lock);

    if (has_timed_out) {
        return FP_TIMEOUT;
    } else {
        return FP_SUCCESS;
    }
}

fp_ret_t cond_signal(fp_cond_t * cond) {
    lock_acquire(cond->lock);
    for (int i = 0; i<NUM_THREADS; i++) {
        if (cond->waiting[i]) {
            cond->waiting[i] = false;
            break;
        }
    }
    lock_release(cond->lock);
    return FP_SUCCESS;
}

fp_ret_t cond_broadcast(fp_cond_t * cond) {
    lock_acquire(cond->lock);
    for (int i = 0; i<NUM_THREADS; i++) {
        cond->waiting[i] = false;
    }
    lock_release(cond->lock);
    return FP_SUCCESS;
}
