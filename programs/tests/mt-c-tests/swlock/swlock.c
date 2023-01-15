/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

lock_t lock = LOCK_INITIALIZER;

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    lock_acquire(&lock);
    *_num += 1;
    _fp_print(*_num);
    lock_release(&lock);
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    lock_acquire(&lock);
    *_num += 2;
    _fp_print(*_num);
    lock_release(&lock);
}

int main() {
    
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    _fp_print(*num);

    thread_t tid[2];
    int errno = thread_create(&tid[0], t1_do_work, num);
    if (errno != 0) _fp_print(666);
    errno = thread_create(&tid[1], t2_do_work, num);
    if (errno != 0) _fp_print(666);

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    _fp_print(*num);

    return 0;
}

