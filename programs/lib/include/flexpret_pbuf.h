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
#include <flexpret_lock.h>

#define PRINT_BUFFER_SIZE (128)

struct PrintBuffer {
    char buffer[PRINT_BUFFER_SIZE];
    volatile uint32_t rdpos;
    volatile uint32_t wrpos;
    fp_lock_t lock;
};

struct PrintBuffer get_new_printbuffer(void);
void printbuffer_pump(struct PrintBuffer *pbuf, char *pump, const uint32_t pump_len);
const uint32_t printbuffer_drain(struct PrintBuffer *pbuf, char *drain);

#endif // FLEXPRET_PBUF_H
