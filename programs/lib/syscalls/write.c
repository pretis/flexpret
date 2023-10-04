#include <stdint.h>
#include <errno.h>
#include <stdbool.h>
#include <string.h>

#include "flexpret.h"

static bool emulation_ignore[NUM_THREADS];

void _write_init(void) {
    for (int i = 0; i < NUM_THREADS; i++) {
        emulation_ignore[i] = true;
    }
}

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
