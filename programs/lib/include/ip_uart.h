#ifndef IP_UART_H
#define IP_UART_H
#include <stdint.h>

typedef struct {
    int pin;
    int baud;
    int _ns_per_bit;
    uint32_t _mask;
} ip_uart_config_t;

void ip_uart_tx_init(ip_uart_config_t *uart);
void ip_uart_tx_send(ip_uart_config_t *uart, char byte);

void ip_uart_rx_init(ip_uart_config_t *uart);
int ip_uart_rx_receive(ip_uart_config_t *uart, char *byte);

#endif