/* A threaded version of add.c */
#include <stdlib.h>
#include <stdint.h>
#include <flexpret/flexpret.h>

fp_lock_t lock = FP_LOCK_INITIALIZER;
fp_cond_t cond = FP_COND_INITIALIZER(&lock);
int count = 0;

void* t1() {
    fp_lock_acquire(&lock);
    fp_cond_wait(&cond);
    count++;
    fp_lock_release(&lock);
    return NULL;
}

void* t2() {
    fp_lock_acquire(&lock);
    fp_cond_wait(&cond);
    count++;
    fp_lock_release(&lock);
    return NULL;
}

int test_signal() {
    count=0;
    fp_thread_t tid[2];
    int errno = fp_thread_create(HRTT, &tid[0], t1, NULL);
    fp_assert(errno == 0, "Could not create thread");
    errno = fp_thread_create(HRTT, &tid[1], t2, NULL);
    fp_assert(errno == 0, "Could not create thread");
    
    fp_delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 0, "Incorrect value for count");
    fp_cond_signal(&cond);

    fp_delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 1, "Incorrect value for count");
    fp_cond_signal(&cond);
    
    fp_delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 2, "Incorrect value for count");


    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);
    return 0;
}

int test_broadcast() {
    count=0;
    fp_thread_t tid[2];
    int errno = fp_thread_create(HRTT, &tid[0], t1, NULL);
    fp_assert(errno == 0, "Could not create thread");
    errno = fp_thread_create(HRTT, &tid[1], t2, NULL);
    fp_assert(errno == 0, "Could not create thread");
    fp_delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 0, "Incorrect value for count");
    fp_cond_broadcast(&cond);
    fp_delay_for(100000);
    printf("count is %i\n", count);
    fp_assert(count == 2, "Incorrect value for count");

    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);
    return 0;
}

void test_timed_wait() {

    fp_lock_acquire(&lock);
    uint64_t t1 = rdtime64();
    printf("t1 is %lli\n", t1);
    uint64_t wakeup = t1 + 100000;
    printf("wakeup is %lli\n", wakeup);

    fp_cond_timed_wait(&cond, wakeup);
    uint64_t t2 = rdtime64();
    printf("t2 is %lli\n", t2);

    fp_assert(t2 > wakeup, "rdtime64() got value less than waketime");   
    fp_lock_release(&lock);
}

int main() {
    
    test_signal();
    test_broadcast();
    test_timed_wait();
}

