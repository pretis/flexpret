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
#include <stdlib.h>
#include <assert.h>

#include "common.h"

#define EVENT_INITIALIZER_SET_PIN(p) (pin_event_t) \
{ .pin = p, .in_n_cycles = 10000, .high_low = HIGH }

#define EVENT_INITIALIZER_CLR_PIN(p) (pin_event_t) \
{ .pin = p, .in_n_cycles = 10000, .high_low = LOW  }

static pin_event_t test_vector_port0[] = {
    // Set and clear pins in some random-ish fashion
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0(0)),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0(2)),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0(7)),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0(3)),
    EVENT_INITIALIZER_SET_PIN(PIN_IO_GPI_0(5)),

    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0(0)),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0(2)),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0(7)),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0(3)),
    EVENT_INITIALIZER_CLR_PIN(PIN_IO_GPI_0(5)),
};

static void make_global_queue(pin_event_t *queue, const int queue_length)
{
    assert(queue);
    for (int i = 1; i < queue_length; i++) {
        queue[i].in_n_cycles += queue[i-1].in_n_cycles;
    }
}

int main(int argc, char const* argv[]) 
{ 
    int client_fd = setup_socket();
    if (client_fd < 0) {
        exit(1);
    }

    make_global_queue(test_vector_port0, sizeof(test_vector_port0) / sizeof(test_vector_port0[0]));

    // Wait for user to press <enter>
    getchar();
    send(client_fd, test_vector_port0, sizeof(test_vector_port0), 0);

    // Wait for another to exit
    getchar();

    close(client_fd);
    return 0; 
}
