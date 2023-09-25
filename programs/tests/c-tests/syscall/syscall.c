#include <stdlib.h>
#include <unistd.h>
#include <sys/time.h>
#include <errno.h>

#include <flexpret.h>

int main() {
    int ret = close(28);
    _fp_print(errno);

    int pid = getpid();
    _fp_print(errno);

    struct timeval tv;
    ret = gettimeofday(&tv, NULL);
    _fp_print(errno);
    _fp_print(tv.tv_sec);
    _fp_print(tv.tv_usec);

    exit(1);

    // Should not be printed
    _fp_print(1);
}
