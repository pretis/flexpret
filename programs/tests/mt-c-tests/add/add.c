/* A threaded version of add.c */
#include <stdlib.h>
#include <flexpret.h>

void* t1_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    hwlock_acquire();
    *_num += 1;
    hwlock_release();
}

void* t2_do_work(void* num) {
    uint32_t* _num = (uint32_t*) num;
    hwlock_acquire();
    *_num += 2;
    hwlock_release();
}

int main() {
    
    uint32_t* num = malloc(sizeof(uint32_t));
    *num = 0;
    printf("num initialized to: %i\n", *num);

    thread_t tid[2];
    int errno = thread_create(HRTT, &tid[0], t1_do_work, num);
    fp_assert(errno == 0, "Could not create thread");
    errno = thread_create(HRTT, &tid[1], t2_do_work, num);
    fp_assert(errno == 0, "Could not create thread");

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    printf("num finished as: %i\n", *num);

    return 0;
}

