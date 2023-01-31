#include <stdint.h>
#include <stdbool.h>

#include "cbuf.h"
#include <flexpret_assert.h>
#include <flexpret_io.h>
#include "tinyalloc/tinyalloc.h"



// The hidden definition of our circular buffer structure
struct cbuf_t {
	uint8_t * buffer;
	size_t head;
	size_t tail;
	size_t max; //of the buffer
	bool full;
};

static void advance_pointer(cbuf_t *me)
{
	assert(me);

	if(me->full)
   	{
		if (++(me->tail) == me->max) 
		{ 
			me->tail = 0;
		}
	}

	if (++(me->head) == me->max) 
	{ 
		me->head = 0;
	}
	me->full = (me->head == me->tail);
}

static void retreat_pointer(cbuf_t *me)
{
	assert(me);

	me->full = false;
	if (++(me->tail) == me->max) 
	{ 
		me->tail = 0;
	}
}


cbuf_t* cbuf_init(uint8_t *buffer, size_t size) {
    assert(buffer && size);

    cbuf_t *me = ta_alloc(sizeof(cbuf_t));
    assert(me);

    me->buffer = buffer;
    me->max = size;

    cbuf_reset(me);
    assert(cbuf_empty(me));

    return me;
}

// Reset the circular buffer to empty, head == tail
void cbuf_reset(cbuf_t* me) {
    assert(me);

    me->head = 0;
    me->tail = 0;
    me-> full = false;
}


void cbuf_free(cbuf_t * me) {
    assert(me);
    ta_free(me);
}

// Retrieve a value from the buffer
// Returns 0 on success, -1 if the buffer is empty
int cbuf_get(cbuf_t* me, uint8_t * data) {
    assert(me && data && me->buffer);

    int r = -1;

    if(!cbuf_empty(me))
    {
        *data = me->buffer[me->tail];
        retreat_pointer(me);

        r = 0;
    }

    return r;
}

// Returns true if the buffer is empty
bool cbuf_empty(cbuf_t* me) {
    assert(me);

	return (!me->full && (me->head == me->tail));   
}

// Returns true if the buffer is full
bool cbuf_full(cbuf_t* me) {
    assert(me);
    return me->full;
}

// Put version 1 continues to add data if the buffer is full
// Old data is overwritten
void cbuf_put_overwrite(cbuf_t* me, uint8_t data) {
    assert(me && me->buffer);
    me->buffer[me->head] = data;
    advance_pointer(me);
}

// Put Version 2 rejects new data if the buffer is full
// Returns 0 on success, -1 if buffer is full
int cbuf_put_reject(cbuf_t* me, uint8_t data) {
    assert(me && me->buffer);
    
    int r = -1;

    if(!cbuf_full(me))
    {
        me->buffer[me->head] = data;
        advance_pointer(me);
        r = 0;
    }
    return r;
}

// Returns the maximum capacity of the buffer
size_t cbuf_capacity(cbuf_t* me) {
    assert(me);
    return me->max;
}

// Returns the current number of elecbufnts in the buffer
size_t cbuf_size(cbuf_t* me) {
    assert(me);
    size_t size = me->max;
    if (!me->full) {
        if (me->head > me->tail) {
            size = me->head - me->tail;
        } else {
            size = me->tail - me->head;
        }
    }
    return size;
}

