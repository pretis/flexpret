#include <flexpret_stdio.h>
#include <flexpret_lock.h>
#include <flexpret_noc.h>

#include <sdd_uart.h>

#define STDIO_UART_PIN 0
#define STDIO_UART_BAUD 115200
#define STDIO_UART_PORT 1
#define STDIO_MAX_DIGITS 32

sdd_uart_config_t uart = {.initialized = false};

void fp_printer_run() {
    uart.pin = STDIO_UART_PIN;
    uart.baud = STDIO_UART_BAUD;
    uart.port = STDIO_UART_PORT;
    uart.buf_size = 8;
    sdd_uart_tx_run(&uart);
}

void fp_printer_int(int val) {
    if (read_coreid() == 0) {
        while (!uart.initialized) {}
    }

    char buf[32];
    int n_digits=0;
    while (val && n_digits<STDIO_MAX_DIGITS) {
        char digit = '0' + (val % 10);
        buf[n_digits++] = digit;
        val = val/10;
    }

    lock_acquire(&uart._lock);
    sdd_uart_tx_send(&uart, &buf[0], n_digits);
    lock_release(&uart._lock);
}

void fp_printer_str(const char *str) {
    if (read_coreid() == 0) {
        while (!uart.initialized) {}
    }
    // Calculate length
    const char *_str = str;
    int length=0;
    int length_words;
    while (*_str != '\0') {
        _str++;
        length++;
    }
    assert(length<256);
    length_words = length/4;
    if (length % 4) {
        length_words++;
    }

    if (read_coreid() == 0) {
        lock_acquire(&uart._lock);
        sdd_uart_tx_send(&uart, (char *) str, length);
        lock_release(&uart._lock);
    } else {
        _fp_print(44);
        noc_send(0, length);
        uint32_t ack = noc_receive();
        assert(ack == 1);
        _fp_print(length_words);
        noc_send_arr(0, (uint32_t *) str, length_words);
    }
}
