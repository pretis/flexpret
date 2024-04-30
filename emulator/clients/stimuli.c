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
#include "../../build/hwconfig.h"

static pin_event_t long_interrupt[] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = HIGH },

    // Wait a long time before setting low again to test that we don't end in
    // an infinite interrupt cycle
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 1000 * FP_THREADS, .high_low = LOW  },    
};

static pin_event_t interrupt[] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = HIGH },

    // Wait FP_THREADS cycles before setting low again so the HW thread gets
    // enough time to react
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = FP_THREADS, .high_low = LOW  },
};

int main(int argc, char *const* argv) 
{
    // Allow emulator to initialize before we connect
    sleep(1);
    int client_fd = setup_socket();
    
    sleep(3);
    if (send(client_fd, long_interrupt, sizeof(long_interrupt), 0) < 0) {
        printf("Could not send long interrupt\n");
    }

    usleep((int) (10e4 * FP_THREADS));

    for (int i = 0; i < 50; i++) {
        if (send(client_fd, interrupt, sizeof(interrupt), 0) < 0) {
            break;
        }
        usleep((int) (5e4 * FP_THREADS));
    }

    close(client_fd);
    return 0; 
}
