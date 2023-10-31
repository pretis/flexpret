/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret.h>

lock_t lock = LOCK_INITIALIZER;
cond_t cond = COND_INITIALIZER(&lock);
int count = 0;

void* t1() {
    lock_acquire(&lock);
    cond_wait(&cond);
    count++;
    lock_release(&lock);
}

void* t2() {
    lock_acquire(&lock);
    cond_wait(&cond);
    count++;
    lock_release(&lock);
}

int test_signal() {
    count=0;
    thread_t tid[2];
    int errno = thread_create(HRTT, &tid[0], t1, NULL);
    fp_assert(errno == 0, "Could not create thread");
    errno = thread_create(HRTT, &tid[1], t2, NULL);
    fp_assert(errno == 0, "Could not create thread");
    
    delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 0, "Incorrect value for count");
    cond_signal(&cond);

    delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 1, "Incorrect value for count");
    cond_signal(&cond);
    
    delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 2, "Incorrect value for count");


    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);
}

int test_broadcast() {
    count=0;
    thread_t tid[2];
    int errno = thread_create(HRTT, &tid[0], t1, NULL);
    fp_assert(errno == 0, "Could not create thread");
    errno = thread_create(HRTT, &tid[1], t2, NULL);
    fp_assert(errno == 0, "Could not create thread");
    delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 0, "Incorrect value for count");
    cond_broadcast(&cond);
    delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 2, "Incorrect value for count");

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);
}

void test_timed_wait() {

    lock_acquire(&lock);
    uint64_t t1 = rdtime64();
    printf("t1 is %i\n", t1);
    uint64_t wakeup = t1 + 100000;
    printf("wakeup is %i\n", wakeup);

    cond_timed_wait(&cond, wakeup);
    uint64_t t2 = rdtime64();
    printf("t2 is %i\n", t2);

    fp_assert(t2 > wakeup, "rdtime64() got value less than waketime");   
    lock_release(&lock);
}

int main() {
    
    test_signal();
    test_broadcast();
    test_timed_wait();
}

