// The syscall implemenations mostly come from
// RISC-V Newlib's libnosys:
// https://github.com/riscvarchive/riscv-newlib/tree/riscv-newlib-3.2.0/libgloss/libnosys.
#include <stdint.h>
#include <errno.h>      // Defines ENOSYS.
#include <sys/time.h>

#include <flexpret_io.h>
#include <flexpret_csrs.h>
#include <flexpret_config.h>
#include <flexpret_time.h>

// See https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
// for more information on re-entry to newlib.
#define __DYNAMIC_REENT__
#define _REENT_SMALL
#include <reent.h>

// FIXME: Need to provide file descriptors to _reents variable
// __FILE __sf[3];

struct _reent _reents[NUM_THREADS] = { 0 };

struct _reent *__getreent(void) {
    uint32_t hartid = read_hartid();
    return &_reents[hartid];
}

int *__errno(void) {
    return (int *)__getreent();
}

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
// Syscall implementations
////////////////////////////////////////////////////////////////////////////////

int _close (int fd) {
    errno = ENOSYS;
    return -1;
}

int _execve (const char *, char *const *, char *const *) {
    errno = ENOSYS;
    return -1;
}

int _fcntl (int, int, int) {
    errno = ENOSYS;
    return -1;
}

int _fork (void) {
    errno = ENOSYS;
    return -1;
}

int _fstat (int, struct stat *) {
    errno = ENOSYS;
    return -1;
}

int _getpid (void) {
    errno = ENOSYS;
    return -1;
}

int _isatty (int) {
    errno = ENOSYS;
    return -1;
}

int _kill (int, int) {
    errno = ENOSYS;
    return -1;
}

int _link (const char *, const char *) {
    errno = ENOSYS;
    return -1;
}

_off_t _lseek (int, _off_t, int) {
    errno = ENOSYS;
    return -1;
}

int _mkdir (const char *, int) {
    errno = ENOSYS;
    return -1;
}

int _open (const char *, int, int) {
    errno = ENOSYS;
    return -1;
}

_ssize_t _read (int, void *, size_t) {
    errno = ENOSYS;
    return -1;
}

int _rename (const char *, const char *) {
    errno = ENOSYS;
    return -1;
}

// FIXME: This should not be actually called because of tinyalloc.
void *_sbrk(int incr) {
   extern char   end; /* Set by linker.  */
   static char * heap_end;
   char *        prev_heap_end;

   if (heap_end == 0)
     heap_end = & end;

   prev_heap_end = heap_end;
   heap_end += incr;

   return (void *) prev_heap_end;
}

int _stat (const char *, struct stat *) {
    errno = ENOSYS;
    return -1;
}

_CLOCK_T_ _times (struct tms *) {
    errno = ENOSYS;
    return -1;
}

int _unlink (const char *) {
    errno = ENOSYS;
    return -1;
}

int _wait (int *) {
    errno = ENOSYS;
    return -1;
}

_ssize_t _write (int, const void *, size_t) {
    errno = ENOSYS;
    return -1;
}

int _gettimeofday(struct timeval *__tp, void *__tzp) {
    errno = 0;
    uint64_t ns = rdtime64();
    __tp->tv_sec  = ns_to_s(ns);
    __tp->tv_usec = ns_to_us(ns % (int) (1e9));
    return 0;
}

void _exit (int) {
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}
