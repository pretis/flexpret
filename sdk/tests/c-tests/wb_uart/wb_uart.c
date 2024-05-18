#include <flexpret/flexpret.h>
#include <stdlib.h>

uint8_t file_txt[] = {
    #include "file.txt.h"
};
uint32_t file_txt_len = sizeof(file_txt);

int main(void) {
    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    char *file = malloc(file_txt_len);
    if (!file) {
        printf("File too big to malloc; cannot print it after test\n");
    }
    for (uint32_t i = 0; i < file_txt_len; i++) {
        uint8_t byte = uart_receive();
        fp_assert(file_txt[i] == byte, "Bytes not as expected\n");
        if (file) file[i] = byte;
    }

    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    uint32_t j = 0;
    do {
        printf("File[%li]:\n%s\n", j, &file[512*j]);
    } while (j++ < (file_txt_len / 512));

    fp_assert(uart_available(), "Uart is not available when expected to be\n");

    for (uint32_t i = 0; i < file_txt_len; i++) {
        uart_send(file_txt[i]);
    }

    return 0;
}
