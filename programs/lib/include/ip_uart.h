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
} ip_uart_config_t;

void ip_uart_tx_byte(ip_uart_config_t *uart, char byte);
void ip_uart_tx_run(ip_uart_config_t *uart);
void ip_uart_tx_send(ip_uart_config_t *uart, char byte);
void ip_uart_tx_send_arr(ip_uart_config_t *uart, char *byte, size_t len);


void ip_uart_rx_run(ip_uart_config_t *uart);
int ip_uart_rx_receive(ip_uart_config_t *uart, char *byte);

#endif