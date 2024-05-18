/**
 * @file flexpret_pbuf.h
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A printbuffer API so any thread can write to the Wishbone UART. 
 *        The UART is only accessible by tid = 0, so the printbuffer
 *        basically implements a method to transmit strings from one
 *        tid to another.
 * 
 *        Use pump to transmit strings and drain to receive the strings. 
 * 
 * @copyright Copyright (c) 2024
 * 
 */

#ifndef FLEXPRET_PBUF_H
#define FLEXPRET_PBUF_H

#include <stdint.h>
#include <flexpret/lock.h>

#define PRINT_BUFFER_SIZE (128)
#define PRINTBUFFER_INITIALIZER \
(struct PrintBuffer) { \
    .rdpos = 0, \
    .wrpos = 0, \
    .lock = FP_LOCK_INITIALIZER, \
}

/**
 * A buffer to transfer strings from one hardware thread to another.
 * The lock is used to synchronize the reader and writer threads.
 * 
 */
struct PrintBuffer {
    char buffer[PRINT_BUFFER_SIZE];
    volatile uint32_t rdpos;
    volatile uint32_t wrpos;
    fp_lock_t lock;
};

/**
 * @brief Write strings from the current thread into the buffer. Typically, threads
 *        not connected to its own UART device should be doing this.
 * 
 * @param pbuf The print buffer to write to
 * @param pump The string to write
 * @param pump_len The length of the string to write (suggest using `strlen`)
 */
void printbuffer_pump(struct PrintBuffer *pbuf, char *pump, const uint32_t pump_len);

/**
 * @brief Read strings from the current thread. Typically, threads connected to
 *        its own UART device should be doing this, and write the string to
 *        the UART device after.
 * 
 * @param pbuf The print buffer to read from
 * @param drain The string will be read into this buffer. The user should allocate
 *              a buffer large enough to store the expected string. If unsure,
 *              use `PRINT_BUFFER_SIZE`.
 * @return The number of bytes drained. Can be used e.g., to write all the 
 *         bytes read to the UART device.
 */
uint32_t printbuffer_drain(struct PrintBuffer *pbuf, char *drain);

#endif // FLEXPRET_PBUF_H
