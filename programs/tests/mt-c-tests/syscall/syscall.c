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

    printf("Test success\n");

    return 0;
}

