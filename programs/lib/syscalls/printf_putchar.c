/**
 * @file printf_putchar.c
 * @author Magnus Mæhlum (magnusmaehlum@outlook.com)
 * 
 * The ../printf submodule implements printf(), but the function calls putchar_()
 * which needs to be defined by the user - as per the submodule's documentation.
 * 
 * This code implements the putchar_() function which either calls
 * _write_emulation() or _write_fpga() based on the __EMULATOR__ and
 * __FPGA__ defines.
 * 
 */

#include <stdint.h>
#include <errno.h>
#include <stdbool.h>
#include <string.h>

#include "flexpret.h"

int _write_emulation(int fd, const void *ptr, int len) {
    int tid = read_hartid();

    // To understand the protocol, see the emulator's printf_fsm.c comments
    write_tohost_tid(tid, CSR_TOHOST_PRINTF);
    write_tohost_tid(tid, fd);

    write_tohost_tid(tid, CSR_TOHOST_PRINTF);
    write_tohost_tid(tid, len);

    const int nwords = len / 4;
    uint32_t word;

    for (int i = 0; i < nwords+1; i++) {
        memcpy(&word, ptr, sizeof(uint32_t));
        write_tohost_tid(tid, CSR_TOHOST_PRINTF);
        write_tohost_tid(tid, word);
        ptr += sizeof(uint32_t);
    }

  	return len;
}

int _write_fpga(int fd, const void *ptr, int len) {
    // TODO: Implement UART comm here
    errno = ENOSYS;
    return -1;
}

void putchar_(char character) {
    static lock_t putlock = LOCK_INITIALIZER;
    static unsigned char buffer[64];
    static int i = 0;

    int tid = read_hartid();

    if (character != '\0') {
        if (putlock.locked && putlock.owner == tid) {
            buffer[i++] = character;
        } else {
            lock_acquire(&putlock);
            buffer[i++] = character;
        }
    } else {
#ifdef __EMULATOR__
        _write_emulation(1, buffer, i);
#else
        _write_fpga(1, buffer, i);
#endif // __EMULATOR__
        memset(buffer, 0, i);
        i = 0;
        lock_release(&putlock);
    }
}