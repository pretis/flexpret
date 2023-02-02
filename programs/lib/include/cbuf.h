#ifndef FLEXPRET_BUFFER_H
#define FLEXPRET_BUFFER_H

#include <stdint.h>
#include <stddef.h>

// A circular buffer copied from https://embeddedartistry.com/blog/2017/05/17/creating-a-circular-buffer-in-c-and-c/
//  with minor modifications

typedef struct cbuf_t cbuf_t;

cbuf_t* cbuf_init(uint8_t *buffer, size_t size);

// Reset the circular buffer to empty, head == tail
void cbuf_reset(cbuf_t* cbuf);

// Put version 1 continues to add data if the buffer is full
// Old data is overwritten
void cbuf_put_overwrite(cbuf_t* cbuf, uint8_t data);

// Put Version 2 rejects new data if the buffer is full
// Returns 0 on success, -1 if buffer is full
int cbuf_put_reject(cbuf_t* cbuf, uint8_t data);

// Retrieve a value from the buffer
// Returns 0 on success, -1 if the buffer is empty
int cbuf_get(cbuf_t* cbuf, uint8_t * data);

// Returns true if the buffer is empty
bool cbuf_empty(cbuf_t* cbuf);

// Returns true if the buffer is full
bool cbuf_full(cbuf_t* cbuf);

// Returns the maximum capacity of the buffer
size_t cbuf_capacity(cbuf_t* cbuf);

// Returns the current number of elecbufnts in the buffer
size_t cbuf_size(cbuf_t* cbuf);

#endif