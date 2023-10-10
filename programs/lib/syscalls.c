// The syscall implemenations mostly come from
// RISC-V Newlib's libnosys:
// https://github.com/riscvarchive/riscv-newlib/tree/riscv-newlib-3.2.0/libgloss/libnosys.
#include <stdint.h>
#include <errno.h>      // Defines ENOSYS.
#include <sys/stat.h>   // Defines struct stat.
#include <flexpret_io.h>

int errno;

int _close(int fildes) {
    errno = ENOSYS;
    return -1;
}

// FIXME: Does this also work on the FPGA?
void _exit(int rc) {
    _fp_finish();
    while(1) {}
    __builtin_unreachable();
}

int _fstat(int fildes, struct stat *st) {
    errno = ENOSYS;
    return -1;
}

int _getpid(void){
    errno = ENOSYS;
    return -1;
}

int _isatty(int file) {
    errno = ENOSYS;
    return 0;
}

int _kill(int pid, int sig) {
    errno = ENOSYS;
    return -1;
}

int _lseek(int file, int ptr, int dir) {
    errno = ENOSYS;
    return -1;
}

int _read (int file, char *ptr, int len) {
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

int _write (int file, char *ptr, int len) {
  	errno = ENOSYS;
  	return -1;
}
