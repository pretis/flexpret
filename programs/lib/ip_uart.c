#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_time.h>
#include <flexpret_lock.h>
#include <flexpret_noc.h>

#include <cbuf.h>
#include "tinyalloc/tinyalloc.h"

#include <stdbool.h>
#include <ip_uart.h>

#define BILLION 1000000000UL
#define READ_LATENCY 300*CLOCK_PERIOD_NS


void ip_uart_tx_byte(ip_uart_config_t *uart, char byte) {
    // Start bit
    unsigned int next_event = rdtime();
    gpo_clear(uart->port, uart->_mask);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
    // Write byte
    for (int i = 0; i<8; i++) {
        if ((byte >> i) & 0x01) {
            gpo_set(uart->port, uart->_mask);
        } else {
            gpo_clear(uart->port, uart->_mask);
        }
        next_event += uart->_ns_per_bit;
        delay_until(next_event);
    }
    // Stop bit
    gpo_set(uart->port, uart->_mask);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
}


void ip_uart_tx_run(ip_uart_config_t *uart) {
    // Calculate nsec per bit
    uart->_ns_per_bit = BILLION/uart->baud;

    // Create mask
    uart->_mask = (1 << uart->pin);

    // Initialize lock
    uart->_lock.locked = false;
    uart->_lock.owner = UINT32_MAX;

    // Create cbuf
    uint8_t *buffer = ta_alloc(uart->buf_size * sizeof(uint8_t));
    uart->_cbuf = cbuf_init(buffer, uart->buf_size);

    // Initialize pin to high
    gpo_set(uart->port, uart->_mask);

    uart->initialized = true;
    
    uint8_t tx_byte;
    uint32_t noc_rx;
    int length, received;
    uint32_t recv_buffer[64]; // Max line length is 256 chars

    while(true) {
        // Infinite while loop where IP service is running
        // There are 2 possible inputs:
        // 1. We receive data through the circular buffer
        if(cbuf_get(uart->_cbuf, &tx_byte) == 0) {
            length = tx_byte;
            received = 0;
            while (received < length) {
                if(cbuf_get(uart->_cbuf, &tx_byte) == 0) {
                    ip_uart_tx_byte(uart, (char) tx_byte);
                    received++;
                }
            }   
        }

        // 2. We receive data over the NOC
        // FIXME: All data that is received from the core is printed. AND
        //  we can only receive some data at the time.
        if(NOC_DATA_AVAILABLE(NOC_CSR)) {
            length = noc_receive();
            assert(length<256);
            int src = NOC_SOURCE;
            noc_send(src, 1); // ACK
            int word_length = length/4;
            if (length % 4) {
                word_length++;
            }

            for (int i=0; i<word_length; i++) {
                recv_buffer[i] = noc_receive();
            }

            uint8_t * rx_data = (uint8_t *) &recv_buffer[0];
            for (int i=0; i<length; i++) {
                ip_uart_tx_byte(uart, (char) *rx_data);
                rx_data++;
            }
        }
    }
}


// FIXME: uart_config should be const?
void ip_uart_tx_send(ip_uart_config_t *uart, char *byte, size_t len) {
    assert(len<256);
    while(cbuf_put_reject(uart->_cbuf, (uint8_t) len) != 0) {}
    for (int i=0; i<len; i++) {
        while(cbuf_put_reject(uart->_cbuf, byte[i]) != 0) {}
    }
}