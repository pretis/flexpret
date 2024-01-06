#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include "../../programs/lib/include/flexpret_hwconfig.h"

/**
 * The finite state machine (fsm) is designed with three states: EXPECT_DELIM, 
 * EXPECT_FD, and EXPECT_DATA. The "protocol" between the CPU and the
 * emulator is as follows:
 * 
 * 1. The CPU transmits a delimiter (in this case, 0xFFFFFFFF)
 * 2. The CPU transmits the file descriptor it is printing to
 * 3. The CPU transmits a delimiter
 *      while bytes received < length of data:
 *          4a. The CPU transmits one word of data
 *          4b. The CPU transmits a delimiter
 * 
 * The state transitions associated with one message are:
 * 
 * EXCEPT_DELIM -> EXPECT_FD   -> EXPECT_DELIM -> EXPECT_DATA ->
 * EXPECT_DELIM -> EXPECT_DATA -> EXPECT_DELIM -> EXPECT_DATA -> ...
 * EXPECT_DELIM
 * 
 * Where the transitions between EXPECT_DATA -> EXPECT_DELIM -> EXPECT_DATA
 * can occur as many times as there are word inbound.
 * 
 * If for some reason more data needs to be sent before the payload data comes,
 * it should be quite easy to add another state.
 * 
 */

#include <string.h>

enum state {
    EXPECT_DELIM,
    EXPECT_FD,
    EXPECT_DATA,
};

static enum state state[NUM_THREADS];
static enum state next_state[NUM_THREADS];

static int fd[NUM_THREADS];
static int nbytes_received[NUM_THREADS];
static char buffer[NUM_THREADS][0x2000];

void printf_init(void) {
    for (int i = 0; i < NUM_THREADS; i++) {
        state[i] = EXPECT_DELIM;
        next_state[i] = EXPECT_FD;
        fd[i] = 0;
        nbytes_received[i] = 0;
        memset(buffer[i], 0, sizeof(buffer[i]));
    }
}

static inline int _contains_terminator(const uint32_t word) {
    for (int i = 0; i < sizeof(word); i++) {
        if ((word & (0xFF << (i*8))) == 0) {
            return i;
        }
    }

    return -1;
}

void printf_fsm(const int tid, const uint32_t reg) {
    switch (state[tid])
    {
    case EXPECT_DELIM:
        if (reg == 0xFFFFFFFF) {
            state[tid] = next_state[tid];
        }
        break;

    case EXPECT_FD:
        if (reg != 0xFFFFFFFF) {
            fd[tid] = reg;
            state[tid] = EXPECT_DELIM;
            next_state[tid] = EXPECT_DATA;
        }
        break;

    case EXPECT_DATA:
        if (reg != 0xFFFFFFFF) {
            state[tid] = EXPECT_DELIM;

            int terminator_idx = _contains_terminator(reg);
            if (terminator_idx != -1) {
                memcpy(&buffer[tid][nbytes_received[tid]], &reg, sizeof(uint32_t));
                nbytes_received[tid] = 0;
                next_state[tid] = EXPECT_FD;
#if NUM_THREADS > 1
                printf("[%i]: %s", tid, buffer[tid]);
#else
                // Thread id just becomes noise in this case
                printf("%s", buffer);
#endif // NUM_THREADS > 1
            } else {
                memcpy(&buffer[tid][nbytes_received[tid]], &reg, sizeof(uint32_t));
                nbytes_received[tid] += 4;
            }
        }
        break;

    default:
        break;
    }
}
