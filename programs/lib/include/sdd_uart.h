#ifndef IP_UART_H
#define IP_UART_H
#include <stdint.h>
#include <flexpret.h>
#include <cbuf.h>

// FIXME: This API needs to be way better designed. 
// 1. The config struct (pin, port baud etc) and the resources
//  created (lock, cbuf, mask etc) must be separated
// 2. Do we wanna expose a direct API which does not require
//  a thread running the UART by itself?
typedef void (*gpio_write_func)(uint32_t);
typedef uint32_t (*gpio_read_func)();

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
    gpio_read_func _read_func;
    gpio_write_func _write_func;
} sdd_uart_config_t;

void sdd_uart_tx_run(sdd_uart_config_t *uart);
void sdd_uart_tx_send(sdd_uart_config_t *uart, char *byte, size_t len);

// Mainly for internal use
void _sdd_uart_tx_byte(sdd_uart_config_t *uart, char byte);


void sdd_uart_rx_run(sdd_uart_config_t *uart);
fp_ret_t sdd_uart_rx_receive(sdd_uart_config_t *uart, char *byte);

// Mainly for internal use
fp_ret_t _sdd_uart_rx_byte(sdd_uart_config_t *uart, char *byte);

#endif