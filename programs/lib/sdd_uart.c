#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_time.h>
#include <flexpret_lock.h>
#include <flexpret_noc.h>
#include <flexpret_csrs.h>

#include <cbuf.h>
#include "tinyalloc/tinyalloc.h"

#include <stdbool.h>
#include <sdd_uart.h>

#define BILLION 1000000000UL
#define READ_LATENCY 300*CLOCK_PERIOD_NS


void _sdd_uart_tx_byte(sdd_uart_config_t *uart, char byte) {
    uint32_t txs[8];
    uint32_t stop = (1 << uart->pin);

    for (int i = 0; i<8; i++) {
        int bit = (byte >> i) & 0x01;
        txs[i] = (bit << uart->pin);
    }

    // Start bit
    unsigned int next_event = rdtime();
    uart->_write_func(0);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
    
    for (int i = 0; i<8; i++) {
        uart->_write_func(txs[i]);
        next_event +=uart->_ns_per_bit;
        delay_until(next_event);
    }
    
    // Stop bit
    uart->_write_func(stop);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
}


void sdd_uart_tx_run(sdd_uart_config_t *uart) {
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

    // Register write func
    // FIXME: Handle rest of ports
    switch(uart->port) {
        case 1: uart->_write_func=&gpo_write_1; break;
        default: assert(false);
    }

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
                    _sdd_uart_tx_byte(uart, (char) tx_byte);
                    received++;
                }
            }   
        }

        // 2. We receive data over the NOC
        // FIXME: All data that is received from the core is printed. AND
        //  we can only receive some data at the time.
        if(NOC_DATA_AVAILABLE(NOC_CSR)) {
            noc_receive((uint32_t*)&length, TIMEOUT_FOREVER);
            assert(length<256);
            int src = NOC_SOURCE;
            noc_send(src, 1, TIMEOUT_FOREVER); // ACK
            int word_length = length/4;
            if (length % 4) {
                word_length++;
            }

            for (int i=0; i<word_length; i++) {
                noc_receive(&recv_buffer[i], TIMEOUT_FOREVER);
            }

            uint8_t * rx_data = (uint8_t *) &recv_buffer[0];
            for (int i=0; i<length; i++) {
                _sdd_uart_tx_byte(uart, (char) *rx_data);
                rx_data++;
            }
        }
    }
}


void sdd_uart_tx_send(sdd_uart_config_t *uart, char *byte, size_t len) {
    assert(len<256);
    while(cbuf_put_reject(uart->_cbuf, (uint8_t) len) != 0) {}
    for (int i=0; i<len; i++) {
        while(cbuf_put_reject(uart->_cbuf, byte[i]) != 0) {}
    }
}



// Macro for reading out a single bit from a port
#define READ_BIT(read_func, pin) ((read_func() >> pin) & 0x01)
#define START_OVERHEAD_NSEC 100

fp_ret_t _sdd_uart_rx_byte(sdd_uart_config_t *uart, char *rx) {
    
    char _rx = 0;
    uint32_t start, next_sample;

    // Wait for valid inactive mode
    while ((READ_BIT(uart->_read_func, uart->pin)) == 0) {};


    // Wait for start bit
    while ((READ_BIT(uart->_read_func, uart->pin)) == 1) {};
    start = rdtime() - START_OVERHEAD_NSEC;
    next_sample = start + uart->_ns_per_bit + uart->_ns_per_bit/2;
    delay_until(next_sample);

    // Read out byte
    for (int i=0; i<8; i++) {
        _rx |= (READ_BIT(uart->_read_func, uart->pin)) << i;
        next_sample += uart->_ns_per_bit;
        delay_until(next_sample);
    }

    // Read stop bit
    int stop_bit = (READ_BIT(uart->_read_func, uart->pin));

    // Verify stop bit
    if (stop_bit == 0) {
        gpo_set(0,128);
        return FP_FAILURE;
    }

    *rx = _rx;
    return FP_SUCCESS;
}

void sdd_uart_rx_run(sdd_uart_config_t *uart) {
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

    // Register read func
    // FIXME: Handle rest of ports
    switch(uart->port) {
        case 1: uart->_read_func=&gpi_read_1; break;
        default: assert(false);
    }

    uart->initialized = true;
    
    uint8_t rx_byte;

    while(true) {
        if (_sdd_uart_rx_byte(uart, &rx_byte) == FP_SUCCESS) {
            cbuf_put_overwrite(uart->_cbuf, rx_byte);
        }
    }
}

fp_ret_t sdd_uart_rx_receive(sdd_uart_config_t *uart, char * rx) {
    while(cbuf_get(uart->_cbuf, rx) != 0) {};
    return FP_SUCCESS;
}