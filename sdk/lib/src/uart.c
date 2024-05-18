#include <flexpret/wb.h>
#include <flexpret/uart.h>
#include <flexpret/assert.h>

void uart_send(uint8_t data) {
    while (UART_TX_FULL(wb_read(UART_CSR)));
    wb_write(UART_TXD, data);
}

bool uart_available(void) {
    /**
     * The UART device has a register that contains a magic number
     * `UART_CONST_VALUE`. The sole purpose of this is to check whether
     * we can use the UART device.
     *
     */
    return wb_read(UART_CONST_ADDR) == UART_CONST_VALUE;
}

uint8_t uart_receive(void) {
    while(!UART_DATA_READY(wb_read(UART_CSR)));
    return wb_read(UART_RXD);
}
