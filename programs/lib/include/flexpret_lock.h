#include <flexpret_csrs.h>
#include <flexpret_io.h>

#ifndef FLEXPRET_LOCK_H
#define FLEXPRET_Lock_H

static inline void lock_acquire() {
    while(swap_csr(CSR_HWLOCK, 1) == 0) {}
}

static inline void lock_release() {
    if (swap_csr(CSR_HWLOCK, 0) != 1) {
        _fp_print(666);
        _fp_finish();
    };
}

#endif // FLEXPRET_CSRS_H