#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include "../../programs/lib/include/flexpret_config.h"

/**
 * The finite state machine (fsm) is designed with four states: EXPECT_DELIM, 
 * EXPECT_FD, EXPECT_LEN, and EXPECT_DATA. The "protocol" between the CPU and the
 * emulator is as follows:
 * 
 * 1. The CPU transmits a delimiter (in this case, 0xFFFFFFFF)
 * 2. The CPU transmits the file descriptor it is printing to
 * 3. The CPU transmits a delimiter
 * 4. The CPU transmits the length of the following data
 * 5. The CPU transmits a delimiter
 *      while bytes received < length of data:
 *          6a. The CPU transmits one word of data
 *          6b. The CPU transmits a delimiter
 * 
 * The state transitions associated with one message are:
 * 
 * EXCEPT_DELIM -> EXPECT_FD   -> EXPECT_DELIM -> EXPECT_LEN  -> 
 * EXPECT_DELIM -> EXPECT_DATA -> EXPECT_DELIM -> EXPECT_DATA -> ...
 * EXPECT_DELIM
 * 
 * Where the transitions between EXPECT_DATA -> EXPECT_DELIM -> EXPECT_DATA
 * can occur as many times as there are word inbound.
 * 
 */

enum state {
    EXPECT_DELIM,
    EXPECT_FD,
    EXPECT_LEN,
    EXPECT_DATA,
};

static enum state state[NUM_THREADS];
static enum state next_state[NUM_THREADS];

static uint8_t counter[NUM_THREADS];
static int fd[NUM_THREADS];
static int len[NUM_THREADS];
static int nbytes_received[NUM_THREADS];
static char buffer[1024];

void printf_init(void) {
    for (int i = 0; i < NUM_THREADS; i++) {
        state[i] = EXPECT_DELIM;
        next_state[i] = EXPECT_FD;
        counter[i] = 0;
        fd[i] = 0;
        len[i] = 0;
        nbytes_received[i] = 0;
    }
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
            next_state[tid] = EXPECT_LEN;
            counter[tid] = 0;
        } else {
            counter[tid]++;
        }
        break;

    case EXPECT_LEN:
        if (reg != 0xFFFFFFFF) {
            len[tid] = reg;
            state[tid] = EXPECT_DELIM;
            next_state[tid] = EXPECT_DATA;
            counter[tid] = 0;
        } else {
            counter[tid]++;
        }
        break;

    case EXPECT_DATA:
        if (reg != 0xFFFFFFFF) {
            state[tid] = EXPECT_DELIM;
            int diff = len[tid] - nbytes_received[tid];

            if (diff < 4) {
                memcpy(&buffer[nbytes_received[tid]], &reg, sizeof(uint32_t));
                nbytes_received[tid] += diff;
                buffer[nbytes_received[tid]+1] = '\0';
                nbytes_received[tid] = 0;
                next_state[tid] = EXPECT_FD;
                dprintf(fd[tid], "[%i]: %s", tid, buffer);
            } else {
                memcpy(&buffer[nbytes_received[tid]], &reg, sizeof(uint32_t));
                nbytes_received[tid] += 4;
            }
            counter[tid] = 0;
        } else {
            counter[tid]++;
        }
        break;

    default:
        break;
    }
}
