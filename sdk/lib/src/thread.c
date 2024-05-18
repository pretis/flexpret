#include <stdbool.h>
#include <setjmp.h>
#include <flexpret/flexpret.h>

#include <errno.h>

#include <errno.h>

/*************************************************
 * FlexPRET's hardware thread scheduling functions
 * These functions assume that a lock is held
 * by the caller.
 *************************************************/

/**
 * @brief Set a complete schedule.
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * @param slots An array of slot values
 * @param length The length of the array
 * @return int If success, return 0, otherwise an error code.
 */
int slot_set(slot_t slots[], uint32_t length) {
    if (length > 8) {
        fp_assert(false, "No more than 8 slots supported: %i given\n", (int) length);
        return 1;
    }
    uint32_t val = 0;
    for (uint32_t i = 0; i < length; i++) {
        val |= slots[i] << (i * 4);
    }
    write_csr(CSR_SLOTS, val);
    return 0;
}

/**
 * @brief Allocate a slot for a hard real-time thread (HRTT).
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * @param slot The slot to be allocated
 * @param hartid The hartid of the HRTT
 * @return int If success, return 0, otherwise an error code.
 */
int slot_set_hrtt(uint32_t slot, uint32_t hartid) {
    if (slot > 7) {
        // FIXME: Panic.
        fp_assert(false, "Invalid slot set: %i given\n", (int) slot);
        return 1;
    }
    if (hartid > FP_THREADS) {
        // FIXME: Panic.
        fp_assert(false, "Hardware thread id out of bounds\n");
        return 2;
    }
    uint32_t mask = 0xf << (slot * 4);
    uint32_t val_prev = read_csr(CSR_SLOTS);
    // Use hartid. Each slot is 4-bit wide.
    uint32_t val_new = (val_prev & ~mask) | (hartid << (slot * 4));
    write_csr(CSR_SLOTS, val_new);
    return 0;
}

/**
 * @brief Allocate a slot for a soft real-time thread (SRTT).
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * @param slot The slot to be allocated
 * @return int If success, return 0, otherwise an error code.
 */
int slot_set_srtt(uint32_t slot) {
    if (slot > 7) {
        // FIXME: Panic.
        return 1;
    }
    uint32_t mask = 0xf << (slot * 4);
    uint32_t val_prev = read_csr(CSR_SLOTS);
    // Use SLOT_S. Each slot is 4-bit wide.
    uint32_t val_new = (val_prev & ~mask) | (SLOT_S << (slot * 4));
    write_csr(CSR_SLOTS, val_new);
    return 0;
}

/**
 * @brief Disable a slot in the FlexPRET schedule.
 * 
 * @param slot The slot to be disabled
 * @return int If success, return 0, otherwise an error code.
 */
int slot_disable(uint32_t slot) {
    if (slot > 7) {
        // FIXME: Panic.
        return 1;
    }
    uint32_t mask = 0xf << (slot * 4);
    uint32_t val_prev = read_csr(CSR_SLOTS);
    // Use SLOT_D. Each slot is 4-bit wide.
    uint32_t val_new = (val_prev & ~mask) | (SLOT_D << (slot * 4));
    write_csr(CSR_SLOTS, val_new);
    return 0;
}

/**
 * @brief Get the thread mode of a hardware thread.
 * 
 * @param hartid The hardware thread ID
 * @return tmode_t The current thread mode
 */
tmode_t tmode_get(uint32_t hartid) {
    if (hartid > FP_THREADS) {
        // FIXME: Panic.
        return 1;
    }
    uint32_t mask = 0xf << (hartid * 2);
    uint32_t val_prev = read_csr(CSR_TMODES);
    return (val_prev & ~mask) >> (hartid * 2);
}

/**
 * @brief Set the thread mode of a hardware thread.
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * FIXME: The current hardware does not allow a thread
 * to put itself to sleep because of the read and write
 * involved. We should separate the tmodes register
 * into eight different tmodes so that each thread
 * can turn itself to sleep.
 * 
 * @param hartid The hardware thread ID
 * @param val The thread mode to be set
 * @return int If success, return 0, otherwise an error code.
 */
int tmode_set(uint32_t hartid, tmode_t val) {
    if (hartid > FP_THREADS) {
        // FIXME: Panic.
        return 1;
    }
    uint32_t mask = 0xf << (hartid * 2);
    uint32_t val_prev = read_csr(CSR_TMODES);
    uint32_t val_new = (val_prev & ~mask) | (val << (hartid * 2));
    write_csr(CSR_TMODES, val_new); // Each slot is 4-bit wide.
    return 0;
}

/**
 * @brief Put the thread to sleep based on its current thread mode.
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * FIXME: tmode_active is a bad name since active is an adjactive.
 * Should probably renamed to tmode_wakeup.
 * 
 * If the thread is HRTT, then change the tmode to TMODE_HA.
 * If the thread is SRTT, then change the tmode to TMODE_SA.
 */
int tmode_active(uint32_t hartid) {
    uint32_t tmode = tmode_get(hartid);
    if (tmode == TMODE_HZ || tmode == TMODE_HA)
        tmode_set(hartid, TMODE_HA);
    else if (tmode == TMODE_SZ || tmode == TMODE_SA)
        tmode_set(hartid, TMODE_SA);
    else return 1;
    return 0;
}

/**
 * @brief Put the thread to sleep based on its current thread mode.
 * 
 * This function assumes that a mutex lock
 * is held by the caller.
 * 
 * If the thread is HRTT, then change the tmode to TMODE_HZ.
 * If the thread is SRTT, then change the tmode to TMODE_SZ.
 */
int tmode_sleep(uint32_t hartid) {
    uint32_t tmode = tmode_get(hartid);
    if (tmode == TMODE_HA || tmode == TMODE_HZ)
        tmode_set(hartid, TMODE_HZ);
    else if (tmode == TMODE_SA || tmode == TMODE_SZ)
        tmode_set(hartid, TMODE_SZ);
    else return 1;
    return 0;
}

/**
 * @brief Variables to keep track of tread states. They all need to be marked
 *        volatile - otherwise the compiler will optimize away checking them
 *        for changes.
 */

// An array of function pointers
static volatile void*   (*routines[FP_THREADS])(void *);
static volatile void**  args[FP_THREADS];
static volatile void**  exit_code[FP_THREADS];

// Whether a thread is currently executing a routine.
static volatile bool    in_use[FP_THREADS];
static          jmp_buf envs[FP_THREADS];
static volatile bool    cancel_requested[FP_THREADS];

// Accessed in startup.c
bool volatile           exit_requested[FP_THREADS];

// Keep track of the number of threads
// currently processing routines.
// If this is 0, the main thread can
// safely terminate the execution.
volatile uint32_t num_threads_busy = 0;

// Keep track of the number of threads
// currently marked as EXITED.
// FIXME: Once a worker thread exits,
// it should have completed executing
// some pre-registered clean-up handlers.
volatile uint32_t num_threads_exited = 0;


/* Pthreads-like threading library functions */

static int check_args(
    fp_thread_t *hartid,
    void *(*start_routine)(void *)
) {
    if (hartid == NULL) {
        errno = EINVAL;
    } else if (start_routine == NULL) {
        errno = EINVAL;
    } else {
        return 0;
    }
    return -1;
}

static int assign_hartid(
    fp_thread_t hartid,
    void *(*start_routine)(void *),
    void *restrict arg
) {
    routines[hartid] = (volatile void *(*)(void *))(start_routine);
    args[hartid] = arg;
    num_threads_busy += 1;

    // Signal the worker thread to do work.
    in_use[hartid] = true;
    // FIXME: If the thread is asleep,
    // wake up the thread.
    fp_hwlock_release();
    return 0;
}

// Assign a routine to the first available
// hardware thread.
int fp_thread_create(
    bool is_hrtt,   // HRTT = true, SRTT = false
    fp_thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
) {
    UNUSED(is_hrtt);

    if (check_args(hartid, start_routine) < 0) {
        return 1;
    }
    // Allocate an available thread.
    // Cannot allocate to thread 0.
    fp_hwlock_acquire();
    for (uint32_t i = 1; i < FP_THREADS; i++) {
        if (!in_use[i]) {
            *hartid = i;
            return assign_hartid(i, start_routine, arg);
        }
    }
    fp_hwlock_release();
    // All the threads are occupied, return error.
    errno = EBUSY;
    return 1;
}

// Assign a routine to a _specific_
// hardware thread. If the thread is in use,
// return 1. Otherwise, map the routine and return 0.
int fp_thread_map(
    bool is_hrtt,   // HRTT = true, SRTT = false
    fp_thread_t *restrict hartid, // hartid requested by the user
    void *(*start_routine)(void *),
    void *restrict arg
) {
    UNUSED(is_hrtt);

    if (check_args(hartid, start_routine) < 0) {
        return 1;
    }

    // Do an additional check on hartid, since user requests a specific thread here
    if (!(0 < *hartid && *hartid < FP_THREADS)) {
        errno = EINVAL;
        return 1;
    }

    // Allocate an available thread.
    // Cannot allocate to thread 0.
    fp_hwlock_acquire();
    if (!in_use[*hartid]) {
        return assign_hartid(*hartid, start_routine, arg);
    }
    fp_hwlock_release();
    // All the threads are occupied, return error.
    errno = EBUSY;
    return 1;
}

int fp_thread_join(fp_thread_t hartid, void **retval) {
    // FIXME: What if it waits for the long-running thread?
    while(in_use[hartid]); // Wait
    // Get the exit code from the exiting thread.
    fp_hwlock_acquire();
    if (retval) {
        *retval = exit_code[hartid];
    }
    // FIXME: To avoid losing lots of cycles,
    // a worker thread should put itself to sleep.
    // Put the thread to sleep.
    // FIXME: Should we make an idle thread an SRTT?
    fp_hwlock_release();
    return 0;
}

/** 
 * This should be called by a thread
 * that hopes to exit.
 */
void fp_thread_exit(void *retval) {
    uint32_t hartid = read_hartid();
    fp_hwlock_acquire();
    exit_code[hartid] = retval;
    exit_requested[hartid] = true;
    fp_hwlock_release();
    // FIXME: Run cleanup handlers
    // registered using thread_cleanup_push.
    return;
}

int fp_thread_cancel(fp_thread_t hartid) {
    fp_hwlock_acquire(); // FIXME: Unnecessary?
    cancel_requested[hartid] = true;
    fp_hwlock_release();
    return 0;
}

void fp_thread_testcancel() {
    uint32_t hartid = read_hartid();
    fp_hwlock_acquire();
    if (cancel_requested[hartid]) {
        fp_hwlock_release();
        longjmp((long long int *) envs[hartid], 1);
    }
    fp_hwlock_release();
}

/**
 * Main function for a worker thread (hardware threads 1-7).
 */
void worker_main() {
    uint32_t hartid = read_hartid();

    // Save the environment buffer
    // for potential fp_thread_cancel calls.
    // The execution will jump here
    // if a cancellation request is handled.
    int val = setjmp((long long int *) envs[hartid]);
    // Check if the thread returns from longjmp.
    // If so, mark the thread as not in use.
    if (val == 1) {
        fp_hwlock_acquire();
        num_threads_busy -= 1;
        in_use[hartid] = false;
        fp_hwlock_release();
    }
    else if (val != 0) {
        fp_assert(false, "Reached unreachable code");
    }

    while(!exit_requested[hartid]) {
        // FIXME:
        // It is hard for a thread to put
        // itself to sleep, because calling
        // tmode_set_hrtt();
        // requires a thread to grab the lock.
        // But as soon as the thread sleeps,
        // the lock will not be freed.
        // So for now it's the best if
        // thread 0 does it. Maybe
        // the hardware should change.

        if (in_use[hartid]) {            
            // Execute the routine with the argument passed in.
            (*routines[hartid])(args[hartid]);

            // Mark the thread as available again.
            fp_hwlock_acquire();
            num_threads_busy -= 1;
            in_use[hartid] = false;
            fp_hwlock_release();
        }
    }

    // FIXME: Execute clean up handlers here.

    // Increment the counter of exited threads.
    fp_hwlock_acquire();
    num_threads_exited += 1;
    fp_hwlock_release();

    return;
}