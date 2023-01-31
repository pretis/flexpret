#include <flexpret_stdio.h>
#include <flexpret_lock.h>

#include <ip_uart.h>

#define STDIO_UART_PIN 0
#define STDIO_UART_BAUD 115200

ip_uart_config_t uart;
lock_t lock = LOCK_INITIALIZER;

void print_init() {
    uart.pin = STDIO_UART_PIN;
    uart.baud = STDIO_UART_BAUD;
    ip_uart_tx_init(&uart);
}

void print_int(int val) {
    lock_acquire(&lock);
    char buf[64];
    int n_digits=0;
    while (val) {
        char digit = '0' + (val % 10);
        buf[n_digits++] = digit;
        val = val/10;
    }
    for (int i=n_digits-1; i>=0; i--) {
        ip_uart_tx_send(&uart, buf[i]);
    }
    lock_release(&lock);
}


    void print_str(const char *str) {
    lock_acquire(&lock);
    while (*str != '\0') {
        ip_uart_tx_send(&uart, *str);
        str++;
    }
    lock_release(&lock);
}
