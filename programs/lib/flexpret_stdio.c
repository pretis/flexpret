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
    while (val) {
        char digit = '0' + (val % 10);
        ip_uart_tx_send(&uart, digit);
        val = val/10;
    }
    lock_release(&lock);
}


    void print_str(const char *mapsstr[]) {
    lock_acquire(&lock);
    while (*str != '\0') {
        // ip_uart_tx_send(&uart, *str);
        _fp_print(*str);
        str++;
    }
    lock_release(&lock);
}
