#ifndef FLEXPRET_SLEEP_H
#define FLEXPRET_SLEEP_H

#include "flexpret_io.h"

/**
 * Put the current thread to sleep.
 */
static inline int fp_sleep() { return swap_csr(0x530, 0x0); }

/**
 * Wake up thread with given hartid
 */
static inline int fp_wake(uint32_t hartid) { return swap_csr(0x531, hartid); }


#endif // FLEXPRET_SLEEP_H
