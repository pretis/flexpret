/* A threaded version of add.c */
#include <stdlib.h>
#include <errno.h>
#include <string.h>

#include <flexpret/flexpret.h>

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_hwlock_acquire();
    *_num += 1;
    fp_hwlock_release();
    return NULL;
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_hwlock_acquire();
    *_num += 2;
    fp_hwlock_release();
    return NULL;
}

int main() {
    
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    printf("num initialized to: %i\n", (int) *num);

    fp_thread_t tid[2];
    int err = fp_thread_create(HRTT, &tid[0], t1_do_work, num);
    fp_assert(err == 0, "Could not create thread 0: %s\n", strerror(errno));
    err = fp_thread_create(HRTT, &tid[1], t2_do_work, num);
    fp_assert(err == 0, "Could not create thread 1: %s\n", strerror(errno));

    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);

    printf("num finished as: %i\n", (int) *num);

    return 0;
}

