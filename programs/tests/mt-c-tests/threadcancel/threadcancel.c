/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

lock_t lock = LOCK_INITIALIZER;
bool ready = false;

// Intentionally map the do_work functions to
// two different threads.
thread_t tid[2] = {1, 2};

// t1 to be canceled by t2
void* t1_do_work() {
    lock_acquire(&lock);
    ready = true;
    lock_release(&lock);
    while(1) {
        thread_testcancel();
    }
    _fp_print(111); // Not reachable.
}

// t2 to cancel t1
void* t2_do_work() {
    while(!ready);
    thread_cancel(tid[0]);
    _fp_print(222);
}

int main() {

    int errno = thread_map(&tid[0], t1_do_work, NULL);
    if (errno != 0) _fp_print(666);
    errno = thread_map(&tid[1], t2_do_work, NULL);
    if (errno != 0) _fp_print(666);

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    return 0;
}

