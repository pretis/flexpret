
#ifndef FLEXPRET_NOC_H
#define FLEXPRET_NOC_H

#include <stdint.h>
#include "flexpret_wb.h"


// On the Wishbone bus, the UART has address 0
#define UART_TXD 0x0UL
#define UART_RXD 0x4UL
#define UART_CSR 0x8UL
#define UART_CONST_ADDR 0xCUL

#define UART_CONST_VALUE (0x55)

// Macros for parsing the CSR register value
#define UART_DATA_READY(val) (val & 0x01)
#define UART_TX_FULL(val) (val & 0x02)
#define UART_FAULT(val) (val & 0x04)

// Blocking send word
static void uart_send(uint8_t data) {
    while (UART_TX_FULL(wb_read(UART_CSR)));
    wb_write(UART_TXD, data);
}

static void uart_check_connection(void) {
    fp_assert(wb_read(UART_CONST_ADDR) == UART_CONST_VALUE, "uart test failed\n");
}

// Blocking read word
static uint8_t uart_receive() {
    //printf("uart_receive\n");
    //printf("UART_CSR: 0x%.2x\n", wb_read(UART_CSR));
    while(!UART_DATA_READY(wb_read(UART_CSR))) {
    }
    return wb_read(UART_RXD);
}

#endif
