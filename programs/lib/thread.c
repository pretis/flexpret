#include <stdbool.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

/* Arrays that keep track of the status of threads */
static void* (*routines[NUM_THREADS])(void *); // An array of function pointers
static void** args[NUM_THREADS];
static bool exit_requested[NUM_THREADS];
static void** exit_code[NUM_THREADS];
static bool in_use[NUM_THREADS]; // Whether a thread is currently executing a routine.

// Keep track of the number of threads
// currently processing routines.
//
// Hardware threads being not "busy"
// (i.e., running a routine) is not
// enough to terminate the main thread.
// To terminate the main thread,
// all hardware worker threads need
// to be EXITED.
uint32_t num_threads_busy = 0;

// Keep track of the number of threads
// currently processing routines.
uint32_t num_threads_exited = 0;

// More precisely, this is a "thread_map",
// i.e. mapping a routine to a running
// hardware thread.
int thread_create(
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
) {
    // Allocate an available thread.
    // Cannot allocate to thread 0.
    for (int i = 1; i < NUM_THREADS; i++) {
        if (!in_use[i]) {
            hwlock_acquire();
            *hartid = i;
            routines[i] = start_routine;
            args[i] = arg;
            num_threads_busy += 1;
            in_use[i] = true; // Signal the worker thread to do work.
            hwlock_release();
            return 0;
        }
    }
    // All the threads are occupied, return error.
    return 1;
}

int thread_join(thread_t hartid, void **retval) {
    while(in_use[hartid]); // Wait
    // Get the exit code from the exiting thread.
    *retval = exit_code[hartid];
    return 0;
}

void thread_exit(void *retval) {
    uint32_t hartid = read_hartid();
    exit_code[hartid] = retval;
    exit_requested[hartid] = true;
    // FIXME: Run cleanup handlers
    // registered using thread_cleanup_push.
    return;
}

int thread_cancel(thread_t hartid) {
    exit_requested[hartid] = true;
    return 0;
}

/**
 * Main function for a worker thread (hardware threads 1-7).
 */
void worker_main() {
    uint32_t hartid = read_hartid();

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

    // Increment the counter of exited threads.
    num_threads_exited += 1;

    return;
}
