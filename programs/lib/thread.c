#include <stdbool.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

/* Arrays that keep track of the status of worker threads */
static void* (*routines[NUM_WORKERS])(void *); // An array of function pointers
static void** args[NUM_WORKERS];
static void** exit_code[NUM_WORKERS];

// Using in_use as a condition variable.
static bool in_use[NUM_WORKERS];
uint32_t num_busy_workers = 0;

int thread_create(
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
) {
    // Allocate an available thread.
    for (int i = 0; i < NUM_THREADS-1; i++) {
        if (!in_use[i]) {
            lock_acquire();
            *hartid = i+1;
            routines[i] = start_routine;
            args[i] = arg;
            num_busy_workers += 1;
            in_use[i] = true; // Signal the worker thread to do work.
            lock_release();
            return 0;
        }
    }
    // All the threads are occupied, return error.
    return 1;
}

int thread_join(thread_t hartid, void **retval) {
    uint32_t worker_id = hartid - 1;
    while(in_use[worker_id]); // Wait
    // Get the exit code from the exited thread.
    *retval = exit_code[worker_id];
    return 0;
}

/**
 * Main function for a worker thread (hardware threads 1-7).
 */
void worker_main(uint32_t hartid) {
    uint32_t worker_id = hartid - 1;
    // FIXME: Instead of an infinite loop,
    // need to check for a global shutdown.
    while(1) {
        if (in_use[worker_id]) {
            break; // FIXME: Temporarily only execute routines once.            
        }
    }

    // Execute the routine with the argument passed in.
    (*routines[worker_id])(args[worker_id]);

    // Mark the thread as available again.
    lock_acquire();
    num_busy_workers -= 1;
    in_use[worker_id] = false;
    lock_release();

    return;
}