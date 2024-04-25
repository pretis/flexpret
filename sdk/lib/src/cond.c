#include <flexpret/flexpret.h>
#include <flexpret/cond.h>

fp_ret_t fp_cond_wait(fp_cond_t * cond) {
    int hartid = read_hartid();
    cond->waiting[hartid] = true;
    fp_lock_release(cond->lock);
    while(cond->waiting[hartid]) {}
    fp_lock_acquire(cond->lock);
    return FP_SUCCESS;
}

fp_ret_t fp_cond_timed_wait(fp_cond_t * cond, uint64_t timeout) {
    bool has_timed_out = false;
    int hartid = read_hartid();
    cond->waiting[hartid] = true;
    fp_lock_release(cond->lock);
    while(cond->waiting[hartid] && !has_timed_out) {
        has_timed_out = (rdtime64() >= timeout);
    }
    fp_lock_acquire(cond->lock);

    if (has_timed_out) {
        return FP_TIMEOUT;
    } else {
        return FP_SUCCESS;
    }
}

fp_ret_t fp_cond_signal(fp_cond_t * cond) {
    fp_lock_acquire(cond->lock);
    for (int i = 0; i < FP_THREADS; i++) {
        if (cond->waiting[i]) {
            cond->waiting[i] = false;
            break;
        }
    }
    fp_lock_release(cond->lock);
    return FP_SUCCESS;
}

fp_ret_t fp_cond_broadcast(fp_cond_t * cond) {
    fp_lock_acquire(cond->lock);
    for (int i = 0; i < FP_THREADS; i++) {
        cond->waiting[i] = false;
    }
    fp_lock_release(cond->lock);
    return FP_SUCCESS;
}
