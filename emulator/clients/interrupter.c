/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A simple client that can be used with the emulator when the --client
 * option is given to the emulator. It sets up two pin events that the emulator
 * will use to set the pin high and then low again immediately after. This could
 * be used to emulate receiving an external interrupt.
 * 
 * One interrupt is triggered for each character given to stdin. The user could
 * have both the emulator and this client running in two terminals and see
 * how the emulated FlexPRET reacts to getting interrupts.
 * 
 * The simplest way to transmit just one intterrupt is just to press <enter>.
 * 
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>

#include "common.h"

static pin_event_t interrupt[] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 10000, .high_low = HIGH },
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0,     .high_low = LOW  },
};

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();

    while (1) {
        getchar();
        send(client_fd, interrupt, sizeof(interrupt), 0);
    }
  
    close(client_fd); 
    return 0; 
}
