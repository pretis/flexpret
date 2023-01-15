/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

lock_t lock = LOCK_INITIALIZER;

void* t1_do_work() {
    lock_acquire(&lock);
}

void* t2_do_work() {
    lock_release(&lock);
}

int main() {

    // Intentionally map the do_work functions to
    // two different threads.
    thread_t tid[2] = {1, 2};

    // Map t1_do_work to thread 1 specifically by
    // calling thread_map() instead of thread_create().
    //
    // If we use thread_create(), t2_do_work will be mapped
    // to thread 1 again after it returns from
    // t1_do_work and the exception does not get triggered.
    int errno = thread_map(&tid[0], t1_do_work, NULL);
    if (errno != 0) _fp_print(666);
    void * exit_code_t1;
    thread_join(tid[0], &exit_code_t1);

    // Map t2_do_work to thread 2 specifically.
    // Expect an exception raised by thread 2.
    errno = thread_map(&tid[1], t2_do_work, NULL);
    if (errno != 0) _fp_print(666);
    void * exit_code_t2;
    thread_join(tid[1], &exit_code_t2);

    return 0;
}

