/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret/flexpret.h>
#include <flexpret/lock.h>
#include <flexpret/thread.h>

fp_lock_t lock = FP_LOCK_INITIALIZER;

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_lock_acquire(&lock);
    *_num += 1;
    printf("num is %i\n", (int) *_num);
    fp_lock_release(&lock);
    return NULL;
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_lock_acquire(&lock);
    *_num += 2;
    printf("num is %i\n", (int) *_num);
    fp_lock_release(&lock);
    return NULL;
}

int main() {
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    printf("num is %i\n", (int) *num);

    fp_thread_t tid[2];
    int errno = fp_thread_create(HRTT, &tid[0], t1_do_work, num);
    fp_assert(errno == 0, "Could not create thread\n");
    errno = fp_thread_create(HRTT, &tid[1], t2_do_work, num);
    fp_assert(errno == 0, "Could not create thread\n");

    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);

    printf("num is %i\n", (int) *num);

    return 0;
}

