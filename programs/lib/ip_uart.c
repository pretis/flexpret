#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_time.h>
#include <stdbool.h>
#include <ip_uart.h>

#define BILLION 1000000000UL
#define READ_LATENCY 300*CLOCK_PERIOD_NS 

// FIXME: We are now hardcoded to gpio_1. THis is not a good idea
//  we should improve the io library to avoid this
void ip_uart_tx_init(ip_uart_config_t *uart) {
    // Calculate nsec per bit
    uart->_ns_per_bit = BILLION/uart->baud;

    // Create mask
    uart->_mask = (1 << uart->pin);

    // Initialize pin to high
    gpo_set_1(uart->_mask);
}

void ip_uart_tx_send(ip_uart_config_t *uart, char byte) {
    // Start bit
    unsigned int next_event = rdtime();
    gpo_clear_1(uart->_mask);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
    // Write byte
    for (int i = 0; i<8; i++) {
        if ((byte >> i) & 0x01) {
            gpo_set_1(uart->_mask);
        } else {
            gpo_clear_1(uart->_mask);
        }
        next_event += uart->_ns_per_bit;
        delay_until(next_event);
    }
    // Stop bit
    gpo_set_1(uart->_mask);
    next_event += uart->_ns_per_bit;
    delay_until(next_event);
}



void ip_uart_rx_init(ip_uart_config_t *uart) {
    // Calculate nsec per bit
    uart->_ns_per_bit = BILLION/uart->baud;

    _fp_print(uart->_ns_per_bit);
    // Create mask
    uart->_mask = (1 << uart->pin);
}

typedef enum {
    WAIT_FOR_ACTIVE_STATE,
    WAIT_FOR_START_BIT,
    RECEIVE,
    WAIT_FOR_STOP_BIT
} uart_rx_state_t;

int ip_uart_rx_receive(ip_uart_config_t *uart, char *byte) {

    uart_rx_state_t state = WAIT_FOR_ACTIVE_STATE;
    uint32_t next_event;
    bool done=false;
    int return_code;
    char rx_tmp;

    while(!done) {

        switch(state) {
            case WAIT_FOR_ACTIVE_STATE: {
                if ((gpi_read_1() & uart->_mask) == 1) {
                    state = WAIT_FOR_START_BIT;
                }
                break;   
            }

            case WAIT_FOR_START_BIT: {
                if ((gpi_read_1() & uart->_mask) == 0) {
                    next_event = rdtime() + uart->_ns_per_bit + uart->_ns_per_bit/2 - READ_LATENCY;
                    gpo_write_0(0xFF);
                    state = RECEIVE;
                    rx_tmp = 0;
                }
                break;   
            }

            case RECEIVE: {
                // Read byte
                for (int i = 0; i<8; i++) {
                    delay_until(next_event);
                    rx_tmp |= (gpi_read_1() & uart->_mask) << i;
                    gpo_write_0(i);
                    gpo_write_2(rx_tmp);
                    next_event += uart->_ns_per_bit;
                }
                state = WAIT_FOR_STOP_BIT;
            }

            case WAIT_FOR_STOP_BIT: {
                delay_until(next_event);
                if (gpi_read_1() & uart->_mask) {
                    *byte = rx_tmp;
                    return_code=0;
                } else {
                    return_code=1;
                }
                done=true;
                break;
            }
        }
    }
    return return_code;
}