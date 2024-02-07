#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_assert.h>
#include <flexpret_uart.h>


int main(void) {
    gpo_set_ledmask(0x55);
    while (1) {
        uint8_t byte = uart_receive();
        gpo_set_ledmask(byte);
        uart_send(byte);
    }
}
