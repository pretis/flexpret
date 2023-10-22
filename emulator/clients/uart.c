/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A simple client that can be used with the emulator when the --client
 * option is given to the emulator. It takes a character from the user and wraps
 * it inside signals that are expected from UART communication. Specifically,
 * 
 *      <start bit> <8 data bits> <stop bit>.
 * 
 * Other configurations of UART are of course possible (e.g., parity bit), but 
 * this would require slight alterations to this code.
 * 
 * One transmission is triggered for each character given to stdin. The user could
 * have both the emulator and this client running in two terminals and see
 * how the emulated FlexPRET reacts to getting UART communication.
 * 
 * The simplest way to transmit data is either just pressing <enter> to transmit
 * the ASCII equivalent of <enter> or type something followed by <enter> to transmit
 * more at once. E.g., UUAA<enter> should emulate five bytes.
 * 
 */

#include <stdio.h> 
#include <string.h> 
#include <unistd.h> 
#include <stdbool.h>
#include <sys/socket.h>

#include "common.h"

#define CLOCK_FREQUENCY ((uint32_t)(100e6))  // MHz
#define UART_BAUDRATE   (115200)             //  Hz
#define CLOCKS_PER_BAUD (CLOCK_FREQUENCY / UART_BAUDRATE)

#define EVENT_INITIALIZER(highlow) (pin_event_t) \
{ .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = CLOCKS_PER_BAUD, .high_low = highlow }

static void set_pinevent_uart(char c, pin_event_t *events)
{
    // Pull low to initialize communication
    events[0] = EVENT_INITIALIZER(LOW);

    // Set all data bits
    for (int i = 0; i < 8; i++) {
        events[i+1] = EVENT_INITIALIZER((bool) (c & 0x01));
        c = (c >> 1);
    }

    // Set high to send stop bit
    events[9] = EVENT_INITIALIZER(HIGH);
}

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();

    // Start by setting the pin high
    pin_event_t set_high = EVENT_INITIALIZER(HIGH);
    send(client_fd, &set_high, sizeof(set_high), 0);

    // 10 = 1 start bit + 8 data bits + 1 stop bit
    static pin_event_t events[10];
    while (1) {
        char input = getchar();
        set_pinevent_uart(input, events);
        send(client_fd, events, sizeof(events), 0);
    }
  
    // closing the connected socket 
    close(client_fd); 
    return 0; 
}
