/* A threaded version of add.c */
#include <stdlib.h>
#include <flexpret.h>

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_hwlock_acquire();
    *_num += 1;
    fp_hwlock_release();
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    fp_hwlock_acquire();
    *_num += 2;
    fp_hwlock_release();
}

int main() {
    
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    printf("num initialized to: %i\n", *num);

    fp_thread_t tid[2];
    int errno = fp_thread_create(HRTT, &tid[0], t1_do_work, num);
    fp_assert(errno == 0, "Could not create thread");
    errno = fp_thread_create(HRTT, &tid[1], t2_do_work, num);
    fp_assert(errno == 0, "Could not create thread");

    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);

    printf("num finished as: %i\n", *num);

    return 0;
}

