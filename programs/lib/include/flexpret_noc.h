#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>
#include "flexpret_wb.h"

// Addresses on the NOC wishbone device
#define NOC_CSR 0x0UL
#define NOC_DATA 0x04UL
#define NOC_SOURCE 0x08UL
#define NOC_DEST 0x08UL

// Macros for parsing the CSR register value
#define NOC_TX_READY(val) (val & 0x01)
#define NOC_DATA_AVAILABLE(val) (val & 0x02)


// Blocking send word
static void noc_send(uint32_t addr, uint32_t data) {
    while (!NOC_TX_READY(wb_read(NOC_CSR))) {}
    wb_write(NOC_DEST, addr);
    wb_write(NOC_DATA, data);
}

// Blocking read word
static uint32_t noc_receive() {
    while(!NOC_DATA_AVAILABLE(wb_read(NOC_CSR))) {}
    return wb_read(NOC_DATA);
}

#endif
