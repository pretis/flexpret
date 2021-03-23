#ifndef FLEXPRET_IO_H
#define FLEXPRET_IO_H

#include "encoding.h"
#include "flexpret_const.h"

// TODO: move to flexpret_debug?
// Some should be in .c file...

#if defined(DEBUG_EMULATOR) || defined(STATS_EMULATOR)
#define debug_string(s) emulator_outputstr(s);
#endif


// Convert number to string in hex format
char qbuf[9];
char* itoa_hex(n)
unsigned int n;
{
    register int i;
    for(i = 7; i >= 0; i--) {
        qbuf[i] = (n & 15) + 48;
        if(qbuf[i] >= 58) {
            qbuf[i] += 7;
        }
        n = n >> 4;
    }
    qbuf[8] = '\0';
    return(qbuf);
}

// Emulator (puts bits on bus)
#define EMULATOR_ADDR 0x40000000

// Write each character in the string to a pre-defined address.
void emulator_outputstr(char* str) {
    volatile char* addr = (char*) EMULATOR_ADDR;
    while(*str != 0) {
        *addr = *str;
        str++;
    }
}

// TEMP location
static inline uint32_t get_cycle() { return read_csr(cycle); }
static inline uint32_t get_cycleh() { return read_csr(cycleh); }
static inline uint32_t get_instret() { return read_csr(instret); }
static inline uint32_t get_instreth() { return read_csr(instreth); }

struct stats {
    uint32_t cycle;
    uint32_t cycleh;
    uint32_t instret;
    uint32_t instreth;
};

static inline void stats_get(struct stats* s) {
    do {
        s->cycleh = get_cycleh();
        s->instreth = get_instreth();
        s->cycle = get_cycle();
        s->instret = get_instret();
    } while((get_cycleh() != s->cycleh) || (get_instreth() != s->instreth));
}

static inline void stats_print(struct stats* s, struct stats* e) {
    debug_string(itoa_hex(e->cycleh - s->cycleh));
    debug_string(itoa_hex(e->cycle - s->cycle));
    debug_string("\n");
    debug_string(itoa_hex(e->instreth - s->instreth));
    debug_string(itoa_hex(e->instret - s->instret));
    debug_string("\n");
}

#endif
