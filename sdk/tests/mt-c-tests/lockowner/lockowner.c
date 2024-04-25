/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret/flexpret.h>
#include <flexpret/lock.h>
#include <flexpret/thread.h>

fp_lock_t lock = FP_LOCK_INITIALIZER;

void* t1_do_work() {
    fp_lock_acquire(&lock);
    return NULL;
}

void* t2_do_work() {
    fp_lock_release(&lock);
    return NULL;
}

int main() {

    // Intentionally map the do_work functions to
    // two different threads.
    fp_thread_t tid[2] = {1, 2};

    // Map t1_do_work to thread 1 specifically by
    // calling fp_thread_map() instead of fp_thread_create().
    //
    // If we use fp_thread_create(), t2_do_work will be mapped
    // to thread 1 again after it returns from
    // t1_do_work and the exception does not get triggered.
    int errno = fp_thread_map(HRTT, &tid[0], t1_do_work, NULL);
    fp_assert(errno == 0, "Could not create thread\n");
    void * exit_code_t1;
    fp_thread_join(tid[0], &exit_code_t1);

    // Map t2_do_work to thread 2 specifically.
    // Expect an exception raised by thread 2.
    errno = fp_thread_map(HRTT, &tid[0], t2_do_work, NULL);
    fp_assert(errno == 0, "Could not create thread\n");
    
    void * exit_code_t2;
    fp_thread_join(tid[1], &exit_code_t2);

    printf("Test sucess\n");

    return 0;
}

