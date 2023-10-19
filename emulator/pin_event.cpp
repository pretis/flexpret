#include <list>
#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <netinet/in.h> 
#include <sys/socket.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "VVerilatorTop.h"
#include "pin_event.h"

#include "../../programs/lib/include/flexpret_hwconfig.h"

static uint64_t ncycles = 0;
static int new_socket = 0;

static inline void set_pin(uint32_t which_pin, VVerilatorTop *top, uint8_t val)
{
    switch (which_pin)
    {
#if NUM_THREADS >= 1
    case PIN_IO_INT_EXTS_0: top->io_int_exts_0 = val; break;
#endif
#if NUM_THREADS >= 2
    case PIN_IO_INT_EXTS_1: top->io_int_exts_1 = val; break;
#endif
#if NUM_THREADS >= 3
    case PIN_IO_INT_EXTS_2: top->io_int_exts_2 = val; break;
#endif
#if NUM_THREADS >= 4
    case PIN_IO_INT_EXTS_3: top->io_int_exts_3 = val; break;
#endif
#if NUM_THREADS >= 5
    case PIN_IO_INT_EXTS_4: top->io_int_exts_4 = val; break;
#endif
#if NUM_THREADS >= 6
    case PIN_IO_INT_EXTS_5: top->io_int_exts_5 = val; break;
#endif
#if NUM_THREADS >= 7
    case PIN_IO_INT_EXTS_6: top->io_int_exts_6 = val; break;
#endif
#if NUM_THREADS >= 8
    case PIN_IO_INT_EXTS_7: top->io_int_exts_7 = val; break;
#endif
    default:
        assert(0);
    }
}


void eventlist_accept_clients(void) 
{
    int server_fd, valread;
    struct sockaddr_in address;
    int opt = 1;
    int addrlen = sizeof(address);

    // Creating socket file descriptor 
    if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) < 0) { 
        perror("socket failed");
        exit(EXIT_FAILURE);
    } 

    // Forcefully attaching socket to the port 8080 
    if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &opt, sizeof(opt))) {
        perror("setsockopt");
        exit(EXIT_FAILURE);
    }
    address.sin_family = AF_INET;
    address.sin_addr.s_addr = INADDR_ANY;
    address.sin_port = htons(CLIENT_PORT);

    // Forcefully attaching socket to the port 8080 
    if (bind(server_fd, (struct sockaddr*)&address, sizeof(address)) < 0) { 
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    if (listen(server_fd, 3) < 0) {
        perror("listen");
        exit(EXIT_FAILURE);
    }

    if ((new_socket = accept(server_fd, (struct sockaddr*)&address, 
                  (socklen_t*)&addrlen)) < 0) {
        perror("accept");
        exit(EXIT_FAILURE);
    }

    // Set non-blocking mode on socket
    int dontblock = 1;
    ioctl(new_socket, FIONBIO, &dontblock);
}

void eventlist_listen(std::list<pin_event_t> &appendto) {
    static pin_event_t events[128];
    int bytes_read = read(new_socket, events, sizeof(events));
    if (bytes_read < 0) {
        return;
    } else {
        int nevents = bytes_read / sizeof(pin_event_t);
        std::list<pin_event_t> list;
        for (int i = 0; i < nevents; i++) {
            list.push_back(events[i]);
        }

        eventlist_push(appendto, list);
    }
}

void eventlist_set_pin(std::list<pin_event_t> &events, VVerilatorTop *top) {
    if (events.empty()) {
        // Nothing to do
        return;
    } else {
        pin_event_t event = events.front();
        if (event.in_n_cycles == ncycles) {
            printf("event occur @ %li cycles: %s\n", ncycles, 
                event.high_low == HIGH ? "high" : "low");
            events.pop_front();
            set_pin(event.pin, top, event.high_low);
            ncycles = 0;
        } else {
            ncycles++;
        }
    }
}

void eventlist_push(std::list<pin_event_t> &eventlist, 
    const std::list<pin_event_t> &push) {
    eventlist.insert(eventlist.end(), push.cbegin(), push.cend());
}

std::list<pin_event_t> eventlist_get_interrupt(const uint32_t pin, 
    const uint32_t ncycles) {
    return {
        { .pin = pin, .in_n_cycles = ncycles, .high_low = HIGH },
        { .pin = pin, .in_n_cycles = 0,       .high_low = LOW  },
    };
}
