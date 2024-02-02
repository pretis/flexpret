#include "flexpret_wb.h"
#include "flexpret_uart.h"
#include "flexpret_assert.h"

void uart_send(uint8_t data) {
    while (UART_TX_FULL(wb_read(UART_CSR)));
    wb_write(UART_TXD, data);
}

void uart_check_connection(void) {
    fp_assert(wb_read(UART_CONST_ADDR) == UART_CONST_VALUE, "uart test failed\n");
}

uint8_t uart_receive(void) {
    while(!UART_DATA_READY(wb_read(UART_CSR)));
    return wb_read(UART_RXD);
}
