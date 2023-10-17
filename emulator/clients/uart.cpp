#include <stdio.h> 
#include <string.h> 
#include <unistd.h> 
#include <stdbool.h>
#include <string>
#include <sys/socket.h>

#include "common.h"

#define CLOCK_FREQUENCY ((uint32_t)(100e6))  // MHz
#define UART_BAUDRATE   (115200)             //  Hz
#define CLOCKS_PER_BAUD (CLOCK_FREQUENCY / UART_BAUDRATE)

static void set_pinevent_uart(char c, struct PinEvent *events)
{
    // Pull low to initialize communication
    events[0] = {
        .pin = PIN_IO_INT_EXTS_0,
        .in_n_cycles = CLOCKS_PER_BAUD,
        .high_low = LOW,
    };

    // Set all bits
    for (int i = 0; i < 8; i++) {
        events[i+1] = {
            .pin = PIN_IO_INT_EXTS_0,
            .in_n_cycles = CLOCKS_PER_BAUD,
            .high_low = (bool)(c & 0x01),
        };
        c = (c >> 1);
    }

    // Set high to send stop bit
    events[9] = {
        .pin = PIN_IO_INT_EXTS_0,
        .in_n_cycles = CLOCKS_PER_BAUD,
        .high_low = HIGH,
    };
}

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();

    // Start by setting the pin high
    struct PinEvent set_high = {
        .pin = PIN_IO_INT_EXTS_0,
        .in_n_cycles = 0,
        .high_low = HIGH,
    };

    send(client_fd, &set_high, sizeof(set_high), 0);

    // 10 = 1 start bit + 8 data bits + 1 stop bit
    static struct PinEvent events[10];
    while (1) {
        char input = getchar();
        set_pinevent_uart(input, events);
        send(client_fd, events, sizeof(events), 0);
    }
  
    // closing the connected socket 
    close(client_fd); 
    return 0; 
}
