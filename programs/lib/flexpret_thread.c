#include <stdbool.h>
#include <setjmp.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

/* Arrays that keep track of the status of threads */
static void*   (*routines[NUM_THREADS])(void *); // An array of function pointers
static void**  args[NUM_THREADS];
static void**  exit_code[NUM_THREADS];
static bool    in_use[NUM_THREADS]; // Whether a thread is currently executing a routine.
static jmp_buf envs[NUM_THREADS];
static bool    cancel_requested[NUM_THREADS];
       bool    exit_requested[NUM_THREADS]; // Accessed in startup.c

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

// Assign a routine to the first available
// hardware thread.
int thread_create(
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
            in_use[i] = true; // Signal the worker thread to do work.
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
        in_use[*hartid] = true; // Signal the worker thread to do work.
        hwlock_release();
        return 0;
    }
    hwlock_release();
    // All the threads are occupied, return error.
    return 1;
}

int thread_join(thread_t hartid, void **retval) {
    while(in_use[hartid]); // Wait
    // Get the exit code from the exiting thread.
    hwlock_acquire();
    *retval = exit_code[hartid];
    hwlock_release();
    return 0;
}

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
    hwlock_acquire();
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
