#include <stdint.h>
#include <cstdio>
#include <cstdarg>
#include <cstring>
#include "../../programs/lib/include/flexpret_config.h"

enum state {
    IDLE,
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
        state[i] = IDLE;
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
    case IDLE:
        if (reg == 0xFFFFFFFF) {
            state[tid] = next_state[tid];
        }
        break;

    case EXPECT_FD:
        if (reg != 0xFFFFFFFF) {
            fd[tid] = reg;
            state[tid] = IDLE;
            next_state[tid] = EXPECT_LEN;
            counter[tid] = 0;
        } else {
            counter[tid]++;
        }
        break;

    case EXPECT_LEN:
        if (reg != 0xFFFFFFFF) {
            len[tid] = reg;
            state[tid] = IDLE;
            next_state[tid] = EXPECT_DATA;
            counter[tid] = 0;
        } else {
            counter[tid]++;
        }
        break;

    case EXPECT_DATA:
        if (reg != 0xFFFFFFFF) {
            state[tid] = IDLE;
            int diff = len[tid] - nbytes_received[tid];

            if (diff < 4) {
                //buffer[nbytes_received[tid]] = reg;
                memcpy(&buffer[nbytes_received[tid]], &reg, sizeof(uint32_t));
                nbytes_received[tid] += diff;
                buffer[nbytes_received[tid]+1] = '\0';
                nbytes_received[tid] = 0;
                next_state[tid] = EXPECT_FD;
                printf("[%i]: %s", tid, buffer);
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