
#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>
#include "flexpret_wb.h"

// Addresses on the NOC wishbone device
#define UART_TXD 0x0UL
#define UART_RXD 0x4UL
#define UART_CSR 0x8UL

// Macros for parsing the CSR register value
#define UART_DATA_READY(val) (val & 0x01)
#define UART_TX_FULL(val) (val & 0x02)
#define UART_FAULT(val) (val & 0x04)



// Blocking send word
static void uart_send(uint8_t data) {
    while (UART_TX_FULL(wb_read(UART_CSR))) {}
    wb_write(UART_TXD, data);
}

// Blocking read word
static uint8_t uart_receive() {
    while(!UART_DATA_READY(wb_read(UART_CSR))) {}
    return wb_read(UART_RXD);
}

#endif
