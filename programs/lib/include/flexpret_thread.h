#include <stdint.h>

#ifndef NUM_THREADS
#define NUM_THREADS 1
#endif

#ifndef NUM_WORKERS
#define NUM_WORKERS NUM_THREADS-1
#endif

typedef uint32_t thread_t;

int thread_create(
    thread_t *restrict hartid,
    void *(*start_routine)(void *),
    void *restrict arg
);
int thread_join(thread_t thread, void **retval);
void worker_main();