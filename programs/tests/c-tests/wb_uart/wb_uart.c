#include <flexpret.h>
#include <stdlib.h>

#include "file.txt.h"

int main(void) {
    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    char *file = malloc(file_txt_len);
    if (!file) {
        printf("File too big to malloc; cannot print it after test\n");
    }
    for (int i = 0; i < file_txt_len; i++) {
        uint8_t byte = uart_receive();
        fp_assert(file_txt[i] == byte, "Bytes not as expected\n");
        if (file) file[i] = byte;
    }

    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    int j = 0;
    do {
        printf("File[%i]:\n%s\n", j, &file[512*j]);
    } while (j++ < (file_txt_len / 512));

    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    for (int i = 0; i < file_txt_len; i++) {
        uart_send(file_txt[i]);
    }

    //int i = 0;
    //while (i < UART_NBYTES) {
    //    uint8_t uart_status = wb_read(UART_CSR);
    //    printf("uart_status: 0x%.2x\n", uart_status);
    //    if (uart_status & 0x02) {
    //        busy_poll();
    //    } else {
    //        uart_send(0x55*i++);
    //    }
    //}

    printf("Done\n");
}
