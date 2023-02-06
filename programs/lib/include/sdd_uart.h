#ifndef IP_UART_H
#define IP_UART_H
#include <stdint.h>
#include <cbuf.h>


typedef struct {
    bool initialized;
    uint32_t port;
    size_t pin;
    size_t baud;
    size_t buf_size;
    int _ns_per_bit;
    uint32_t _mask;
    cbuf_t * _cbuf;
    lock_t _lock;
} sdd_uart_config_t;

void sdd_uart_tx_byte(sdd_uart_config_t *uart, char byte);
void sdd_uart_tx_run(sdd_uart_config_t *uart);
void sdd_uart_tx_send(sdd_uart_config_t *uart, char *byte, size_t len);


void sdd_uart_rx_run(sdd_uart_config_t *uart);
int sdd_uart_rx_receive(sdd_uart_config_t *uart, char *byte);

#endif