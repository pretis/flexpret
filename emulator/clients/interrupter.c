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
#include <stdbool.h>
#include <stdlib.h>
#include <sys/socket.h>

#include "common.h"
#include "../../build/hwconfig.h"

static void usage(int argc, char *const* argv, char *err)
{
    printf("Error: %s\n", err);
    printf("Usage: %s [-a <-n <number of interrupts> -d <delay time (ms)>>] [-p <pin>]\n" \
           "    where -a denotes 'automatic' mode\n" \
           "          -n is the number of interrupts to send\n" \
           "          -d is the delay between each interrupt in milliseconds\n" \
           "          -p is which pin to trigger interrupts on (0-7)\n", \
            argv[0]
    );

    puts("\nYou wrote:\n");
    for (int i = 0; i < argc; i++) {
        printf("%s ", argv[i]);
    }
    printf("\n");
    fflush(stdout);

    exit(1);
}

int main(int argc, char *const* argv) 
{
    bool manual = true;
    
    // Only relevant when the 'automatic' mode is enabled
    int ninterrupts = 0;
    int delay_ms = 0;

    int pin = 0;
    int opt = 0;
    
    while((opt = getopt(argc, argv, ":an:d:p:")) != -1) {
        switch (opt)
        {
        case 'a':
            // 'Automatic' mode
            manual = false;
            break;
        
        case 'n':
            ninterrupts = atoi(optarg);
            break;

        case 'd':
            delay_ms = atoi(optarg);
            break;
        
        case 'p':
            pin = atoi(optarg);
            if (pin < 0 || pin > 7) {
                usage(argc, argv, "-p <pin> must be between 0-7");
            }
            break;
        
        case '?':
        default:
            printf("%s", optarg);
            usage(argc, argv, "Unexpected argument");
            break;
        }
    }
    
    pin_event_t interrupt[] = {
        { .pin = pin, .in_n_cycles = 10000, .high_low = HIGH },

        // Wait FP_THREADS cycles before setting low again so the HW thread gets
        // enough time to react
        { .pin = pin, .in_n_cycles = FP_THREADS, .high_low = LOW  },
    };


    if (!manual) {
        if (ninterrupts <= 0) {
            usage(argc, argv, "<number of interrupts> was <= 0");
        }

        if (delay_ms <= 0) {
            usage(argc, argv, "<delay> was <= 0");
        }
    } else if (ninterrupts != 0 || delay_ms != 0) {
        usage(argc, argv, "Invalid combination of arguments\n");
    }

    printf("Using %s mode ", manual ? "manual" : "automatic");
    if (!manual) {
        printf("with configuration: ninterrupts: %i, delay_ms: %i", ninterrupts, delay_ms);
    }
    printf("\n\n");

    if (manual) {
        printf("Press <enter> to start\n");
        getchar();
    } else {
        sleep(1);
    }

    int client_fd = setup_socket();
    if (manual) {
        // In this manual mode, an interupt is sent every time the user presses <enter>
        while(1) {
            getchar();
            send(client_fd, interrupt, sizeof(interrupt), 0);
        }
    } else {
        // In this automatic mode, N interrupts are sent automatically with some
        // delay between each interrupt
        for (int i = 0; i < ninterrupts; i++) {
            send(client_fd, interrupt, sizeof(interrupt), 0);
            usleep(1000 * delay_ms);
        }
    }

    close(client_fd); 
    return 0; 
}
