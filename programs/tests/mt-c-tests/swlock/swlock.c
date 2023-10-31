/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret.h>
#include <flexpret_lock.h>
#include <flexpret_thread.h>

fp_lock_t lock = LOCK_INITIALIZER;

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    lock_acquire(&lock);
    *_num += 1;
    printf("num is %i\n", *_num);
    lock_release(&lock);
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    lock_acquire(&lock);
    *_num += 2;
    printf("num is %i\n", *_num);
    lock_release(&lock);
}

int main() {
    
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    printf("num is %i\n", *num);

    fp_thread_t tid[2];
    int errno = thread_create(HRTT, &tid[0], t1_do_work, num);
    fp_assert(errno == 0, "Could not create thread");
    errno = thread_create(HRTT, &tid[1], t2_do_work, num);
    fp_assert(errno == 0, "Could not create thread");

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    printf("num is %i\n", *num);

    return 0;
}

