// The syscall implemenations mostly come from
// RISC-V Newlib's libnosys:
// https://github.com/riscvarchive/riscv-newlib/tree/riscv-newlib-3.2.0/libgloss/libnosys.
#include <stdint.h>
#include <errno.h>      // Defines ENOSYS.
#include <sys/time.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>

#include <flexpret/flexpret.h>

// See https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
// for more information on re-entry to newlib.
#include <reent.h>

#define INITIAL_HEAPSIZE (0x400)

struct _reent _reents[FP_THREADS];
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

static inline uint64_t ns_to_s(const uint64_t ns) {
    return ((uint64_t) (ns) / (uint64_t) (1e9));
}

static inline uint64_t ns_to_us(const uint64_t ns) {
    return ((uint64_t) (ns) / (uint64_t) (1e3));
}

////////////////////////////////////////////////////////////////////////////////
// Syscall implementations
////////////////////////////////////////////////////////////////////////////////

void _exit (int code) {
    if (code == 0) {
        _fp_finish();
    } else {
        _fp_abort("Got exit code: %i\n", code);
    }
    while(1) {}
    __builtin_unreachable();
}

int _close (int fd) {
    UNUSED(fd);

    errno = ENOSYS;
    return -1;
}

int _execve (const char *pathname, char *const *argv, char *const *envp) {
    UNUSED(pathname);
    UNUSED(argv);
    UNUSED(envp);
    
    errno = ENOSYS;
    return -1;
}

int _fcntl (int fd, int cmd, int arg) {
    UNUSED(fd);
    UNUSED(cmd);
    UNUSED(arg);

    errno = ENOSYS;
    return -1;
}

int _fork (void) {
    errno = ENOSYS;
    return -1;
}

int _fstat (int fd, struct stat *st) {
    UNUSED(fd);
    UNUSED(st);

    errno = ENOSYS;
    return -1;
}

int _getpid (void) {
    errno = ENOSYS;
    return -1;
}

int _isatty (int fd) {
    UNUSED(fd);

    errno = ENOSYS;
    return -1;
}

int _kill (int pid, int sig) {
    UNUSED(pid);
    UNUSED(sig);

    errno = ENOSYS;
    return -1;
}

int _link (const char *oldpath, const char *newpath) {
    UNUSED(oldpath);
    UNUSED(newpath);

    errno = ENOSYS;
    return -1;
}

_off_t _lseek (int fd, _off_t offset, int whence) {
    UNUSED(fd);
    UNUSED(offset);
    UNUSED(whence);

    errno = ENOSYS;
    return -1;
}

int _mkdir (const char *pathname, int mode) {
    UNUSED(pathname);
    UNUSED(mode);

    errno = ENOSYS;
    return -1;
}

int _open (const char *path, int flags, int mode) {
    UNUSED(path);
    UNUSED(flags);
    UNUSED(mode);

    errno = ENOSYS;
    return -1;
}

_ssize_t _read (int fd, void *data, size_t nbytes) {
    UNUSED(fd);
    UNUSED(data);
    UNUSED(nbytes);

    errno = ENOSYS;
    return -1;
}

int _rename (const char *oldpath, const char *newpath) {
    UNUSED(oldpath);
    UNUSED(newpath);

    errno = ENOSYS;
    return -1;
}

// Based on the implementation found here: https://sourceware.org/git/gitweb.cgi?p=newlib-cygwin.git;a=blob;f=libgloss/aarch64/syscalls.c
// with some modifications
void *_sbrk(int incr) {
    extern char __sheap; // Set by linker; start of heap space
    extern char __eheap; // Set by linker; max size of the heap (where stack begins)
    static char * heap_end;
    char *        prev_heap_end;

    if (heap_end == 0) {
        heap_end = &__sheap;
    }

    prev_heap_end = heap_end;

    if ((heap_end + incr) > &__eheap) {
        errno = ENOMEM;
        return (void *) -1;
    }

   heap_end += incr;
   return (void *) prev_heap_end;
}

int _stat (const char *path, struct stat *st) {
    UNUSED(path);
    UNUSED(st);

    errno = ENOSYS;
    return -1;
}

_CLOCK_T_ _times (struct tms *tms) {
    UNUSED(tms);

    errno = ENOSYS;
    return -1;
}

int _unlink (const char *path) {
    UNUSED(path);

    errno = ENOSYS;
    return -1;
}

int _wait (int *wstatus) {
    UNUSED(wstatus);

    errno = ENOSYS;
    return -1;
}

_ssize_t _write (int fd, const void *data, size_t nbytes) {
    UNUSED(fd);
    UNUSED(data);
    UNUSED(nbytes);

    errno = ENOSYS;
    return -1;
}

int _gettimeofday(struct timeval *tv, void *tz) {
    UNUSED(tz);

    errno = 0;
    uint64_t ns = rdtime64();
    tv->tv_sec  = ns_to_s(ns);
    tv->tv_usec = ns_to_us(ns % (int) (1e9));
    return 0;
}

////////////////////////////////////////////////////////////////////////////////
// Malloc required functions
////////////////////////////////////////////////////////////////////////////////

static fp_lock_t malloc_lock = FP_LOCK_INITIALIZER;

FP_TEST_OVERRIDE
void __malloc_lock(struct _reent *r)
{
    UNUSED(r);

    fp_lock_acquire(&malloc_lock);
}

FP_TEST_OVERRIDE
void __malloc_unlock(struct _reent *r)
{
    UNUSED(r);

    fp_lock_release(&malloc_lock);
}
