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
        fp_assert(errno == 0, "Errno not as expected");
    }
}

void* t2_close(void* arg) {
    int iterations = (*(int *) arg);
    for (int i = 0; i < iterations; i++) {
        close(22);
        fp_assert(errno == ENOSYS, "Errno not as expected");
    }
}

int main() {
    int iterations = 100;
    fp_thread_t tid[2];
    int ok = fp_thread_create(HRTT, &tid[0], t1_gettimeofday, &iterations);
    fp_assert(ok == 0, "Could not create thread");
    ok = fp_thread_create(HRTT, &tid[1], t2_close, &iterations);
    fp_assert(ok == 0, "Could not create thread");

    void * exit_code_t1;
    void * exit_code_t2;
    fp_thread_join(tid[0], &exit_code_t1);
    fp_thread_join(tid[1], &exit_code_t2);

    // Try to create a thread which does not make sense and expect error code
    fp_thread_t invalid_tid = 99;
    ok = fp_thread_map(HRTT, &invalid_tid, t2_close, NULL);
    fp_assert(ok == 1 && errno == EINVAL, "Error codes not as expected");

    // Try to create a thread with an id already in use and expect error code
    fp_thread_t tid_in_use;
    fp_assert(fp_thread_create(HRTT, &tid_in_use, t2_close, &iterations) == 0, "Could not create thread");
    ok = fp_thread_map(HRTT, &tid_in_use, t2_close, NULL);
    fp_assert(ok == 1 && errno == EBUSY, "Error codes not as expected");

    printf("Test success\n");

    return 0;
}

