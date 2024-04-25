#include <flexpret/pbuf.h>
#include <string.h>

static inline uint32_t printbuffer_get_wrsize(struct PrintBuffer *pbuf) {
    return pbuf->wrpos >= pbuf->rdpos ? (PRINT_BUFFER_SIZE - pbuf->wrpos + pbuf->rdpos)
                                      : (pbuf->rdpos - pbuf->wrpos);
}

static inline uint32_t printbuffer_get_rdsize(struct PrintBuffer *pbuf) {
    return PRINT_BUFFER_SIZE - printbuffer_get_wrsize(pbuf);
}

void printbuffer_pump(struct PrintBuffer *pbuf, char *pump, const uint32_t pump_len) {
    fp_lock_acquire(&pbuf->lock);
    
    const uint32_t writable = printbuffer_get_wrsize(pbuf);
    if (writable >= pump_len) {

        const uint32_t len_until_wrap = PRINT_BUFFER_SIZE - pbuf->wrpos;
        if (pump_len > len_until_wrap) {
            // Wrap around
            memcpy(&pbuf->buffer[pbuf->wrpos], pump, len_until_wrap);
            pbuf->wrpos = 0;
            memcpy(&pbuf->buffer[pbuf->wrpos], &pump[len_until_wrap], pump_len - len_until_wrap);
            pbuf->wrpos = pump_len - len_until_wrap;
        } else {
            memcpy(&pbuf->buffer[pbuf->wrpos], pump, pump_len);
            pbuf->wrpos += pump_len;
        }
    }

    fp_lock_release(&pbuf->lock);
}

uint32_t printbuffer_drain(struct PrintBuffer *pbuf, char *drain) {
    fp_lock_acquire(&pbuf->lock);

    uint32_t rdsize = printbuffer_get_rdsize(pbuf);
    if (rdsize > 0) {
        const uint32_t len_until_wrap = PRINT_BUFFER_SIZE - pbuf->rdpos;
        
        // Find the first string, but search at max until the edge of the buffer
        // (+ 1 for '\0')
        const uint32_t slen = strnlen(&pbuf->buffer[pbuf->rdpos], len_until_wrap) + 1;
        rdsize = slen < rdsize ? slen : rdsize;
        
        // Check whether we need to wrap around the buffer
        if (rdsize > len_until_wrap) {
            // Wrap around
            // 1. Copy end of buffer
            memcpy(drain, &pbuf->buffer[pbuf->rdpos], len_until_wrap);
            pbuf->rdpos = 0;

            // 2. Now begin copying from start of buffer
            const uint32_t left_to_read = strlen(&pbuf->buffer[pbuf->rdpos]) + 1;
            memcpy(&drain[len_until_wrap], &pbuf->buffer[pbuf->rdpos], left_to_read);
            pbuf->rdpos = left_to_read;
            rdsize = len_until_wrap + left_to_read;
        } else {
            memcpy(drain, &pbuf->buffer[pbuf->rdpos], rdsize);
            pbuf->rdpos += rdsize;
        }
    }

    fp_lock_release(&pbuf->lock);
    return rdsize;
}
