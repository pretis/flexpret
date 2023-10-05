/**
 * @file syscall.c
 * @author Magnus Mæhlum (magnusmaehlum@outlook.com)
 * 
 * This test checks both that the system calls in ../../lib/syscalls/syscalls.c
 * work as expected. It also checks that the errno variable works as expected.
 * 
 */

#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <errno.h>

#include <flexpret.h>
#include <flexpret_assert.h>

int main() {
    int ret;
    
    ret = close(28);
    assert(ret == -1, "Return value not as expected");
    assert(errno == ENOSYS, "Errno not as expected");

    ret = getpid();
    assert(ret == -1, "Return value not as expected");
    assert(errno == ENOSYS, "Errno not as expected");

    struct timeval tv;
    ret = gettimeofday(&tv, NULL);
    assert(ret == 0, "Return value not as expected");
    assert(errno == 0, "Errno not as expected");

    printf("tv.tv_sec is %i\n", tv.tv_sec);
    printf("tv.tv_usec is %i\n", tv.tv_usec);

    exit(1);

    // Should never reach this
    assert(0, "Unreachable code reached");
}
