#include <stdint.h>
#include <errno.h>
#include <stdbool.h>
#include <string.h>

#include "flexpret_config.h"
#include "flexpret_io.h"

static bool emulation_ignore[NUM_THREADS];

void _write_init(void) {
    for (int i = 0; i < NUM_THREADS; i++) {
        emulation_ignore[i] = true;
    }
}

int _write_emulation(int fd, const void *ptr, int len) {
    int tid = read_hartid();

    /**
     * For some reason, puts() calls _write twice, with the second write containing
     * just nothing. So we make a simple state machine that just ignores the other
     * one.
     */
    emulation_ignore[tid] = !emulation_ignore[tid];
    
    if (emulation_ignore[tid]) {
        return 0;
    }

    // For simulation purposes:
    // Before each word is written, the magic CSR_TOHOST_PRINTF must be written
    // first. This signals the next data is valid. 
    // Ensure the CSR_TOHOST_PRINTF is not valid ascii characters
    write_tohost_tid(tid, CSR_TOHOST_PRINTF);
    write_tohost_tid(tid, fd);

    write_tohost_tid(tid, CSR_TOHOST_PRINTF);
    write_tohost_tid(tid, len);

    // 4. Write all the data to host
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
