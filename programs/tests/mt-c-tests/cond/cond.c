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
    assert(errno == 0);
    errno = thread_create(HRTT, &tid[1], t2, NULL);
    assert(errno == 0);
    delay_for(100000);
    _fp_print(count);
    assert(count == 0);
    cond_signal(&cond);
    delay_for(100000);
    _fp_print(count);
    assert(count == 1);
    cond_signal(&cond);
    delay_for(100000);
    _fp_print(count);
    assert(count == 2);


    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);
}

int test_broadcast() {
    count=0;
    thread_t tid[2];
    int errno = thread_create(HRTT, &tid[0], t1, NULL);
    assert(errno == 0);
    errno = thread_create(HRTT, &tid[1], t2, NULL);
    assert(errno == 0);
    delay_for(100000);
    _fp_print(count);
    assert(count == 0);
    cond_broadcast(&cond);
    delay_for(100000);
    _fp_print(count);
    assert(count == 2);

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);
}

void test_timed_wait() {

    lock_acquire(&lock);
    uint64_t t1 = rdtime64();
    _fp_print(t1);
    uint64_t wakeup = t1 + 100000;
    _fp_print(wakeup);

    cond_timed_wait(&cond, wakeup);
    uint64_t t2 = rdtime64();
    _fp_print(t2);

    assert(t2 > wakeup);   
    lock_release(&lock);
}

int main() {
    
    test_signal();
    test_broadcast();
    test_timed_wait();
}

