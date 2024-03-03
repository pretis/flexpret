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

static pin_event_t long_interrupt[] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = HIGH },

    // Wait a long time before setting low again to test that we don't end in
    // an infinite interrupt cycle
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 1000 * NUM_THREADS, .high_low = LOW  },    
};

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
    
    sleep(1);
    for (int i = 1; i < NUM_THREADS; i++) {
        pin_event_t long_interrupt_tid[2];
        memcpy(long_interrupt_tid, long_interrupt, sizeof(long_interrupt));
        long_interrupt_tid[0].pin += i;
        long_interrupt_tid[1].pin += i;

        if (send(client_fd, long_interrupt_tid, sizeof(long_interrupt), 0) < 0) {
            printf("Could not send interrupt tid\n");
        }
        usleep((int) (5e4 * NUM_THREADS));
    }

    sleep(1);

    for (int i = 1; i < NUM_THREADS; i++) {
        pin_event_t interrupt_tid[2];
        memcpy(interrupt_tid, interrupt, sizeof(interrupt));
        interrupt_tid[0].pin += i;
        interrupt_tid[1].pin += i;

        if (send(client_fd, interrupt_tid, sizeof(interrupt), 0) < 0) {
            printf("Could not send interrupt tid\n");
        }
        usleep((int) (5e4 * NUM_THREADS));
    }

    usleep((int) (10e4 * NUM_THREADS));

    for (int i = 0; i < 50; i++) {
        if (send(client_fd, interrupt, sizeof(interrupt), 0) < 0) {
            break;
        }
        usleep((int) (5e4 * NUM_THREADS));
    }

    close(client_fd);
    return 0; 
}
