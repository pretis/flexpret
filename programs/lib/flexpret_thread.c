#include <stdbool.h>
#include <setjmp.h>
#include <flexpret_io.h>
#include <flexpret_csrs.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

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
        // FIXME: Panic
        assert(false);
        return 1;
    }
    uint32_t val = 0;
    for (int i = 0; i < length; i++) {
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
        assert(false);
        return 1;
    }
    if (hartid > NUM_THREADS) {
        // FIXME: Panic.
        assert(false);
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
    if (hartid > NUM_THREADS) {
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
    if (hartid > NUM_THREADS) {
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

/* Variables that keep track of the status of threads */

// An array of function pointers
static void*   (*routines[NUM_THREADS])(void *);
static void**  args[NUM_THREADS];
static void**  exit_code[NUM_THREADS];
// Whether a thread is currently executing a routine.
static bool    in_use[NUM_THREADS];
static jmp_buf envs[NUM_THREADS];
static bool    cancel_requested[NUM_THREADS];
// Accessed in startup.c
bool           exit_requested[NUM_THREADS];

// Keep track of the number of threads
// currently processing routines.
// If this is 0, the main thread can
// safely terminate the execution.
uint32_t num_threads_busy = 0;

// Keep track of the number of threads
// currently marked as EXITED.
// FIXME: Once a worker thread exits,
// it should have completed executing
// some pre-registered clean-up handlers.
uint32_t num_threads_exited = 0;


/* Pthreads-like threading library functions */

// Assign a routine to the first available
// hardware thread.
int thread_create(
    bool is_hrtt,   // HRTT = true, SRTT = false
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
) {
    // Allocate an available thread.
    // Cannot allocate to thread 0.
    hwlock_acquire();
    for (int i = 1; i < NUM_THREADS; i++) {
        if (!in_use[i]) {
            *hartid = i;
            routines[i] = start_routine;
            args[i] = arg;
            num_threads_busy += 1;
            // Signal the worker thread to do work.
            in_use[i] = true;
            // FIXME: If the thread is asleep,
            // wake up the thread.
            hwlock_release();
            return 0;
        }
    }
    hwlock_release();
    // All the threads are occupied, return error.
    return 1;
}

// Assign a routine to a _specific_
// hardware thread. If the thread is in use,
// return 1. Otherwise, map the routine and return 0.
int thread_map(
    bool is_hrtt,   // HRTT = true, SRTT = false
    thread_t *restrict hartid, // hartid requested by the user
    void *(*start_routine)(void *),
    void *restrict arg
) {
    // Allocate an available thread.
    // Cannot allocate to thread 0.
    hwlock_acquire();
    if (!in_use[*hartid]) {
        routines[*hartid] = start_routine;
        args[*hartid] = arg;
        num_threads_busy += 1;
        // Signal the worker thread to do work.
        in_use[*hartid] = true;
        // FIXME: If the thread is asleep,
        // wake up the thread.
        hwlock_release();
        return 0;
    }
    hwlock_release();
    // All the threads are occupied, return error.
    return 1;
}

int thread_join(thread_t hartid, void **retval) {
    // FIXME: What if it waits for the long-running thread?
    while(in_use[hartid]); // Wait
    // Get the exit code from the exiting thread.
    hwlock_acquire();
    *retval = exit_code[hartid];
    // FIXME: To avoid losing lots of cycles,
    // a worker thread should put itself to sleep.
    // Put the thread to sleep.
    // FIXME: Should we make an idle thread an SRTT?
    hwlock_release();
    return 0;
}

/** 
 * This should be called by a thread
 * that hopes to exit.
 */
void thread_exit(void *retval) {
    uint32_t hartid = read_hartid();
    hwlock_acquire();
    exit_code[hartid] = retval;
    exit_requested[hartid] = true;
    hwlock_release();
    // FIXME: Run cleanup handlers
    // registered using thread_cleanup_push.
    return;
}

int thread_cancel(thread_t hartid) {
    hwlock_acquire(); // FIXME: Unnecessary?
    cancel_requested[hartid] = true;
    hwlock_release();
    return 0;
}

void thread_testcancel() {
    uint32_t hartid = read_hartid();
    hwlock_acquire();
    if (cancel_requested[hartid]) {
        hwlock_release();
        longjmp(envs[hartid], 1);
    }
    hwlock_release();
}

/**
 * Main function for a worker thread (hardware threads 1-7).
 */
void worker_main() {
    uint32_t hartid = read_hartid();

    // Save the environment buffer
    // for potential thread_cancel calls.
    // The execution will jump here
    // if a cancellation request is handled.
    int val = setjmp(envs[hartid]);
    // Check if the thread returns from longjmp.
    // If so, mark the thread as not in use.
    if (val == 1) {
        hwlock_acquire();
        num_threads_busy -= 1;
        in_use[hartid] = false;
        hwlock_release();

        // Print a magic number that indicates
        // the handling of a cancellation request.
        _fp_print(6662);
    }
    else if (val != 0) {
        // UNREACHABLE
        // FIXME: Use an assert() here instead.
        _fp_print(666);
        _fp_finish();
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
            hwlock_acquire();
            num_threads_busy -= 1;
            in_use[hartid] = false;
            hwlock_release();
        }
    }

    // FIXME: Execute clean up handlers here.

    // Increment the counter of exited threads.
    hwlock_acquire();
    num_threads_exited += 1;
    hwlock_release();

    return;
}
