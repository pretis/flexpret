#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>

#define NOC_BASE 0x40000020UL
#define NOC_CSR (*( (volatile uint32_t *) (NOC_BASE + 0x0UL)))
#define NOC_DATA (*( (volatile uint32_t *) (NOC_BASE + 0x4UL)))
#define NOC_SOURCE (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))
#define NOC_DEST (*( (volatile uint32_t *) (NOC_BASE + 0x8UL)))

// Macros for parsing the CSR register value
#define NOC_TX_READY(val) (val & 0x01)
#define NOC_DATA_AVAILABLE(val) (val & 0x02)

// Blocking send word
static void noc_send(uint32_t addr, uint32_t data) {
    while (!NOC_TX_READY(NOC_CSR)) {}
    NOC_DEST = addr;
    NOC_DATA = data;
}

// Send array, blocking
static void noc_send_arr(uint32_t addr, uint32_t * data, int length) {
    for (int i=0; i<length; i++) {
        while (!NOC_TX_READY(NOC_CSR)) {}
        NOC_DEST = addr; // FIXME: Can we get rid of these?
        NOC_DATA = data[i];
    }
}

// Blocking read word
static uint32_t noc_receive() {
    while(!NOC_DATA_AVAILABLE(NOC_CSR)) {}
    return NOC_DATA;
}

#endif
