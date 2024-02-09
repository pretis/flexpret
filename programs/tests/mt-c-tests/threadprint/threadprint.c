/* A threaded version of add.c */
#include <stdlib.h>
#include <string.h>

#include <flexpret.h>

#define PRINT_BUFFER_SIZE (128)

struct PrintBuffer {
    char buffer[PRINT_BUFFER_SIZE];
    volatile uint32_t rdpos;
    volatile uint32_t wrpos;
    fp_lock_t lock;
};

struct PrintBuffer get_default_printbuffer(void) {
    return (struct PrintBuffer) {
        .rdpos = 0,
        .wrpos = 0,
        .lock = FP_LOCK_INITIALIZER
    };
}

const uint32_t printbuffer_get_wrsize(struct PrintBuffer *pbuf) {
    return pbuf->wrpos >= pbuf->rdpos ? (PRINT_BUFFER_SIZE - pbuf->wrpos + pbuf->rdpos)
                                      : (pbuf->rdpos - pbuf->wrpos);
}

const uint32_t printbuffer_get_rdsize(struct PrintBuffer *pbuf) {
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

void* t1_do_work(void* arg) {
    struct PrintBuffer *printbuf = arg;
    
    char writebuf[128];
    int len = snprintf(writebuf, sizeof(writebuf),
        "Hello world from %i\n", read_hartid());
    
    printbuffer_pump(printbuf, writebuf, len);
    printbuffer_pump(printbuf, writebuf, len);
    printbuffer_pump(printbuf, writebuf, len);
    printbuffer_pump(printbuf, writebuf, len);
}

const uint32_t printbuffer_drain(struct PrintBuffer *pbuf, char *drain) {
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

int main(void) {
    
    struct PrintBuffer t1_printbuf = get_default_printbuffer();
    struct PrintBuffer t2_printbuf = get_default_printbuffer();
    struct PrintBuffer t3_printbuf = get_default_printbuffer();

    int ret = 0;
    fp_thread_t tid[3];

    for (int i = 0; i < 50; i++) {
        ret = fp_thread_create(HRTT, &tid[0], t1_do_work, &t1_printbuf);
        fp_assert(ret == 0, "Could not create thread");
        ret = fp_thread_create(HRTT, &tid[1], t1_do_work, &t2_printbuf);
        fp_assert(ret == 0, "Could not create thread");
        ret = fp_thread_create(HRTT, &tid[2], t1_do_work, &t3_printbuf);
        fp_assert(ret == 0, "Could not create thread");

        fp_thread_join(tid[0], NULL);
        fp_thread_join(tid[1], NULL);
        fp_thread_join(tid[2], NULL);


        char printable[128];
        uint32_t nbytes = 0;
        while ((nbytes = printbuffer_drain(&t1_printbuf, printable)) > 0) {
            //for (int j = 0; j < nbytes; j++) {
            //    uart_send(printable[j]);
            //}
            printf("%s", printable);
        }

        while ((nbytes = printbuffer_drain(&t2_printbuf, printable)) > 0) {
            //for (int j = 0; j < nbytes; j++) {
            //    uart_send(printable[j]);
            //}
            printf("%s", printable);
        }

        while ((nbytes = printbuffer_drain(&t3_printbuf, printable)) > 0) {
            //for (int j = 0; j < nbytes; j++) {
            //    uart_send(printable[j]);
            //}
            printf("%s", printable);
        }
    }

    return 0;
}

