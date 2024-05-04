/**
 * @brief Software-defined (SDD) UART device.
 * 
 * Author: Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * 
 */

#ifndef FLEXPRET_SDD_UART_H
#define FLEXPRET_SDD_UART_H

#include <stdint.h>
#include <stdbool.h>

enum UARTState {
    STATE_STARTBIT,
    STATE_DATABITS,
    STATE_STOPBIT,
};

// TODO: Docuemtn functions
struct RingBuffer {
    // TODO: Strictly speaking should have a mutex

    // TODO: Try remove volatile
    volatile uint32_t wrpos;
    volatile uint32_t rdpos;
    uint8_t buf[64];
};

struct UARTContext {
    int pin;
    uint32_t baudrate_hz;
    enum UARTState state;
    struct RingBuffer rbuf;
    bool enabled;
};

/**
 * @brief Construct a default `struct UARTContext` and return it.
 * 
 * @param port The port to intialize the context for. Can be changed after.
 * @return struct UARTContext 
 */
struct UARTContext sdd_uart_get_default_context(const uint32_t port);

/**
 * @brief 
 * 
 * @param arg 
 * @return void* 
 */
void *sdd_uart_rx(void *arg);

/**
 * @brief 
 * 
 * @param ctx 
 * @return uint8_t 
 */
uint8_t sdd_uart_rx_read(struct UARTContext *ctx);

/**
 * @brief 
 * 
 * @param ctx 
 * @return uint32_t 
 */
uint32_t sdd_uart_rx_bytes_readable(struct UARTContext *ctx);

/**
 * @brief 
 * 
 * @param arg 
 * @return void* 
 */
void *sdd_uart_tx(void *arg);

/**
 * @brief 
 * 
 * @param ctx 
 * @param byte 
 */
void sdd_uart_tx_write(struct UARTContext *ctx, const uint8_t byte);

/**
 * @brief 
 * 
 * @param ctx 
 * @return uint32_t 
 */
uint32_t sdd_uart_tx_bytes_writable(struct UARTContext *ctx);

#endif // FLEXPRET_SDD_UART_H
