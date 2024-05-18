/**
 * @file heap.c
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief Try to malloc from several threads at the same time to check that it
 *        is thread-safe.
 * 
 */

#include <string.h>
#include <stdlib.h>

#include <flexpret/flexpret.h>
#include <flexpret/exceptions.h>

/**
 * These functions are found in ../../lib/syscalls/syscalls.c.
 * 
 * If they are overwritten with nothing, the test will crash. Otherwise, if the
 * implementation in syscalls.c is used, the test will succeed.
 * 
 * Try to comment it in and see for yourself :)
 */
#if 0
void __malloc_lock(struct _reent *r) {}
void __malloc_unlock(struct _reent *r) {}
#endif

void *task_heap_user(void *arg) {
    uint32_t hartid = read_hartid();
    int iterations = (int) arg;
    for (int i = 0; i < iterations; i++) {
        uint32_t *data = malloc(sizeof(uint32_t));
        fp_assert(data, "Could not malloc\n");
        *data = 42 * hartid;
        fp_assert(*data == (42 * hartid), "Data was changed by another thread\n");
        free(data);
    }
    return NULL;
}

int main() {
    fp_thread_t tid[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_assert(fp_thread_create(HRTT, &tid[i], task_heap_user, (void *)100) == 0, 
            "Could not create thread");
    }

    void *exit_codes[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_thread_join(tid[i], &exit_codes[i]);
        fp_assert(exit_codes[i] == 0, "Thread's exit code was non-zero");
    }

    printf("Multiple threads successfully allocated memory on the heap at the same time without corruption\n");

    return 0;
}
