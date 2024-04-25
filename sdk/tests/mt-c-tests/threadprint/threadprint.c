/* A threaded version of add.c */
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include <flexpret/internal/hwconfig.h>
#include <flexpret/pbuf.h>
#include <flexpret/thread.h>
#include <flexpret/types.h>
#include <flexpret/assert.h>
#include <flexpret/uart.h>

void* pumper(void* arg) {
    struct PrintBuffer *printbuf = arg;
    
    char writebuf[128];
    int len = snprintf(writebuf, sizeof(writebuf),
        "Hello world from tid: %i\n", (int) read_hartid());
    
    printbuffer_pump(printbuf, writebuf, len);
    return NULL;
}

int main(void) {
    printf("Hello world from tid: %i\n", (int) read_hartid());
    
    // One more than strictly necessary
    struct PrintBuffer bufs[FP_THREADS] = THREAD_ARRAY_INITIALIZER(
        PRINTBUFFER_INITIALIZER
    );

    int ret = 0;
    fp_thread_t tid[FP_THREADS-1];
    for (int i = 0; i < FP_THREADS-1; i++) {
        ret = fp_thread_create(HRTT, &tid[i], pumper, &bufs[i]);
        fp_assert(ret == 0, "Could not create thread");
    }

    for (int i = 0; i < FP_THREADS-1; i++) {
        fp_thread_join(tid[i], NULL);
    }

    char printable[128];
    for (int i = 0; i < FP_THREADS-1; i++) {
        uint32_t nbytes = 0;
        while ((nbytes = printbuffer_drain(&bufs[i], printable)) > 0) {
            for (uint32_t j = 0; j < nbytes; j++) {
                uart_send(printable[j]);
            }
        }
    }

    return 0;
}

