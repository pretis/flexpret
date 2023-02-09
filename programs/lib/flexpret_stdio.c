#include <flexpret_stdio.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>
#include <sdd_uart.h>

#define STDIO_UART_PIN 0
#define STDIO_UART_BAUD 115200
#define STDIO_UART_PORT_WRITE_FUNC &gpo_write_1
#define STDIO_MAX_DIGITS 32
#define BILLION 1000000000UL

lock_t lock = {.locked = false};

void print_str(const char *str) {
    lock_acquire(&lock);
    sdd_uart_config_t uart;
    uart.baud = STDIO_UART_BAUD;
    uart.pin = 0;
    uart.port = 1;
    uart._mask = (1 << STDIO_UART_PIN);
    uart._ns_per_bit = BILLION / STDIO_UART_BAUD;
    uart._write_func = STDIO_UART_PORT_WRITE_FUNC;

    uart._write_func(uart._mask);
    while (*str != '\0') {
        _sdd_uart_tx_byte(&uart, *str);
        str++;
    }

    uart._write_func(uart._mask);
    lock_release(&lock);
}

void print_int(int val) {
    lock_acquire(&lock);
    sdd_uart_config_t uart;
    uart.baud = STDIO_UART_BAUD;
    uart.pin = 0;
    uart.port = 1;
    uart._mask = (1 << STDIO_UART_PIN);
    uart._ns_per_bit = BILLION / STDIO_UART_BAUD;
    uart._write_func = STDIO_UART_PORT_WRITE_FUNC;

    uart._write_func(uart._mask);

    char buf[32];
    int n_digits=0;
    if (val == 0) {
        buf[n_digits++] = '0';
    }

    while (val && n_digits<STDIO_MAX_DIGITS) {
        char digit = '0' + (val % 10);
        buf[n_digits++] = digit;
        val = val/10;
    }

    for (int i=n_digits-1; i>=0; i--) {
        _sdd_uart_tx_byte(&uart, buf[i]);
    }
    // Print newline
    _sdd_uart_tx_byte(&uart, '\n');
    uart._write_func(uart._mask);
    lock_release(&lock);
}