#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <errno.h>

#include <flexpret.h>
#include <flexpret_assert.h>

int main() {
    int ret;
    
    ret = close(28);
    assert(ret == -1);
    assert(errno == ENOSYS);

    ret = getpid();
    assert(ret == -1);
    assert(errno == ENOSYS);

    struct timeval tv;
    ret = gettimeofday(&tv, NULL);
    assert(ret == 0);
    assert(errno == 0);

    _fp_print(tv.tv_sec);
    _fp_print(tv.tv_usec);

    exit(1);

    // Should never reach this
    assert(0);
}
