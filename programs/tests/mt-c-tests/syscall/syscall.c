/**
 * @file syscall.c
 * @author Magnus Mæhlum (magnusmaehlum@outlook.com)
 * 
 * This is the threaded version of ../../c-tests/syscall/syscall.c
 * Notably, it checks that errno is thread-safe.
 * 
 */

#include <flexpret.h>
#include <flexpret_assert.h>

#include <stdlib.h>
#include <sys/time.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>

void* t1_gettimeofday(void* arg) {
    int iterations = (*(int *) arg);
    struct timeval tv;
    for (int i = 0; i < iterations; i++) {
        gettimeofday(&tv, NULL);
        assert(errno == 0, "Errno not as expected");
    }
}

void* t2_close(void* arg) {
    int iterations = (*(int *) arg);
    for (int i = 0; i < iterations; i++) {
        close(22);
        assert(errno == ENOSYS, "Errno not as expected");
    }
}

int main() {
    int iterations = 100;
    thread_t tid[2];
    int ok = thread_create(HRTT, &tid[0], t1_gettimeofday, &iterations);
    assert(ok == 0, "Could not create thread");
    ok = thread_create(HRTT, &tid[1], t2_close, &iterations);
    assert(ok == 0, "Could not create thread");

    void * exit_code_t1;
    void * exit_code_t2;
    thread_join(tid[0], &exit_code_t1);
    thread_join(tid[1], &exit_code_t2);

    // Try to create a thread which does not make sense and expect error code
    thread_t invalid_tid = 99;
    ok = thread_map(HRTT, &invalid_tid, t2_close, NULL);
    assert(ok == 1 && errno == EINVAL, "Error codes not as expected");

    // Try to create a thread with an id already in use and expect error code
    thread_t tid_in_use;
    assert(thread_create(HRTT, &tid_in_use, t2_close, &iterations) == 0, "Could not create thread");
    ok = thread_map(HRTT, &tid_in_use, t2_close, NULL);
    assert(ok == 1 && errno == EBUSY, "Error codes not as expected");

    printf("Test success\n");

    return 0;
}

