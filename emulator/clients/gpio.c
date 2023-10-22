/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A simple client that can be used with the emulator when the --client
 * option is given to the emulator. It toggles a few GPIO pins for testing purposes,
 * and should toggle pins in accordance with the 
 * ../../programs/tests/c-tests/gpio test.
 * 
 * The GPIO pins are set when the user presses <enter>.
 * 
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/socket.h>

#include "common.h"

#define EVENT_INITIALIZER_SET_PIN(p) (pin_event_t) \
{ .pin = p, .in_n_cycles = 1000, .high_low = HIGH }

#define EVENT_INITIALIZER_CLR_PIN(p) (pin_event_t) \
{ .pin = p, .in_n_cycles = 1000, .high_low = LOW  }

static pin_event_t test_vector[] = {
    // Set and clear pins in some random-ish fashion
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_1),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_2),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_2),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_2),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_3),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0),

    // All pins are now set; clear them in some random-ish fashion
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_2),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_3),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_1),
};

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();

    // Wait for user to press <enter>
    getchar();
    send(client_fd, test_vector, sizeof(test_vector), 0);

    while(1);

    close(client_fd);
    return 0; 
}
