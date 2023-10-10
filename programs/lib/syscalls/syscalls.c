// The syscall implemenations mostly come from
// RISC-V Newlib's libnosys:
// https://github.com/riscvarchive/riscv-newlib/tree/riscv-newlib-3.2.0/libgloss/libnosys.
#include <stdint.h>
#include <errno.h>      // Defines ENOSYS.
#include <sys/time.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>

#include <flexpret.h>

// See https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
// for more information on re-entry to newlib.
#include <reent.h>

struct _reent _reents[NUM_THREADS];
struct _reent *__getreent(void) {
    uint32_t hartid = read_hartid();
    return &_reents[hartid];
}

int *__errno(void) {
    return &_REENT->_errno;
}

char *__env[] = { 0 };
char **environ;

////////////////////////////////////////////////////////////////////////////////
// Helper functions
////////////////////////////////////////////////////////////////////////////////

static inline const uint64_t ns_to_s(const uint64_t ns) {
    return ((uint64_t) (ns) / (uint64_t) (1e9));
}

static inline const uint64_t ns_to_us(const uint64_t ns) {
    return ((uint64_t) (ns) / (uint64_t) (1e3));
}

////////////////////////////////////////////////////////////////////////////////
// Initialization
////////////////////////////////////////////////////////////////////////////////

void syscalls_init(void) {
    _impure_ptr = &_reents[0];
    environ = &__env[0];
}

////////////////////////////////////////////////////////////////////////////////
// Syscall implementations
////////////////////////////////////////////////////////////////////////////////

void _exit (int code) {
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}

int _close (int fd) {
    errno = ENOSYS;
    return -1;
}

int _execve (const char *pathname, char *const *argv, char *const *envp) {
    errno = ENOSYS;
    return -1;
}

int _fcntl (int fd, int cmd, int arg) {
    errno = ENOSYS;
    return -1;
}

int _fork (void) {
    errno = ENOSYS;
    return -1;
}

int _fstat (int fd, struct stat *st) {
    errno = ENOSYS;
    return -1;
}

int _getpid (void) {
    errno = ENOSYS;
    return -1;
}

int _isatty (int fd) {
    errno = ENOSYS;
    return -1;
}

int _kill (int pid, int sig) {
    errno = ENOSYS;
    return -1;
}

int _link (const char *oldpath, const char *newpath) {
    errno = ENOSYS;
    return -1;
}

_off_t _lseek (int fd, _off_t offset, int whence) {
    errno = ENOSYS;
    return -1;
}

int _mkdir (const char *pathname, int mode) {
    errno = ENOSYS;
    return -1;
}

int _open (const char *path, int flags, int mode) {
    errno = ENOSYS;
    return -1;
}

_ssize_t _read (int fd, void *data, size_t nbytes) {
    errno = ENOSYS;
    return -1;
}

int _rename (const char *oldpath, const char *newpath) {
    errno = ENOSYS;
    return -1;
}

// FIXME: This should not be actually called because of tinyalloc.
void *_sbrk(int incr) {
   extern char   __end; /* Set by linker.  */
   static char * heap_end;
   char *        prev_heap_end;

   if (heap_end == 0)
     heap_end = &__end;

   prev_heap_end = heap_end;
   heap_end += incr;

   return (void *) prev_heap_end;
}

int _stat (const char *path, struct stat *st) {
    errno = ENOSYS;
    return -1;
}

_CLOCK_T_ _times (struct tms *tms) {
    errno = ENOSYS;
    return -1;
}

int _unlink (const char *path) {
    errno = ENOSYS;
    return -1;
}

int _wait (int *wstatus) {
    errno = ENOSYS;
    return -1;
}

_ssize_t _write (int fd, const void *data, size_t nbytes) {
    errno = ENOSYS;
    return -1;
}

int _gettimeofday(struct timeval *tv, void *tz) {
    errno = 0;
    uint64_t ns = rdtime64();
    tv->tv_sec  = ns_to_s(ns);
    tv->tv_usec = ns_to_us(ns % (int) (1e9));
    return 0;
}
