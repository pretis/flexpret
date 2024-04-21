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

#include <flexpret/flexpret.h>

int main() {
    int ret;
    
    ret = close(28);
    fp_assert(ret == -1, "Return value not as expected");
    fp_assert(errno == ENOSYS, "Errno not as expected");

    ret = getpid();
    fp_assert(ret == -1, "Return value not as expected");
    fp_assert(errno == ENOSYS, "Errno not as expected");

    struct timeval tv;
    ret = gettimeofday(&tv, NULL);
    fp_assert(ret == 0, "Return value not as expected");
    fp_assert(errno == 0, "Errno not as expected");

    printf("tv.tv_sec is %lli\n", tv.tv_sec);
    printf("tv.tv_usec is %li\n", tv.tv_usec);

    exit(0);

    // Should never reach this
    fp_assert(0, "Unreachable code reached");
}
