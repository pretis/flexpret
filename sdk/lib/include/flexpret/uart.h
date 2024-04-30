
#ifndef FLEXPRET_UART_H
#define FLEXPRET_UART_H

#include <stdbool.h>
#include <stdint.h>
#include <flexpret/wb.h>


// On the Wishbone bus, the UART has address 0
#define UART_TXD 0x0UL
#define UART_RXD 0x4UL
#define UART_CSR 0x8UL
#define UART_CONST_ADDR 0xCUL

#define UART_CONST_VALUE (0x55)

// Macros for parsing the CSR register value
#define UART_DATA_READY(val) (val & 0x01)
#define UART_TX_FULL(val) (val & 0x02)
#define UART_FAULT_BAD_ADDR(val) (val & 0x04)

/**
 * @brief Write data over UART using with the wishbone interface
 * 
 * @param data The data to write
 */
void uart_send(uint8_t data);

/**
 * @brief Check that there is a connection to the wishbone UART interface
 *        by reading a magic number from it. 
 *
 * @return True if available, false otherwise. 
 */
bool uart_available(void);

/**
 * @brief Receive a byte over UART using the wishbone interface
 * 
 * @return The byte read
 */
uint8_t uart_receive(void);

#endif // FLEXPRET_UART_H
