/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief A simple client that is coupled with the interrupt.c test. It provides
 *        20 interrupts with some delay, which the test needs.
 * 
 */

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <stdlib.h>
#include <sys/socket.h>

#include "common.h"
#include "../../programs/lib/include/flexpret_hwconfig.h"

static pin_event_t interrupt[] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = HIGH },

    // Wait NUM_THREADS cycles before setting low again so the HW thread gets
    // enough time to react
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = NUM_THREADS, .high_low = LOW  },
};

int main(int argc, char *const* argv) 
{
    // Allow emulator to initialize before we connect
    sleep(1);
    int client_fd = setup_socket();
    
    sleep(3);
    for (int i = 0; i < 20; i++) {
        if (send(client_fd, interrupt, sizeof(interrupt), 0) < 0) {
            break;
        }
        usleep((int) 3e5);
    }

    close(client_fd);
    return 0; 
}
