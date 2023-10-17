#include <list>
#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <netinet/in.h> 
#include <sys/socket.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include "pin_event.h"

static uint64_t ncycles = 0;
static int new_socket = 0;

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

void eventlist_listen(std::list<struct PinEvent> &appendto) {
    static struct PinEvent events[128];
    int bytes_read = read(new_socket, events, sizeof(events));
    if (bytes_read < 0) {
        return;
    } else {
        int nevents = bytes_read / sizeof(struct PinEvent);
        std::list<struct PinEvent> list;
        for (int i = 0; i < nevents; i++) {
            list.push_back(events[i]);
        }

        eventlist_push(appendto, list);
    }
}

void eventlist_set_pin(std::list<struct PinEvent> &events, uint8_t *pin) {
    if (events.empty()) {
        // Nothing to do
        return;
    } else {
        struct PinEvent event = events.front();
        if (event.in_n_cycles == ncycles) {
            printf("event occur @ %li cycles: %s\n", ncycles, 
                event.high_low == HIGH ? "high" : "low");
            events.pop_front();
            *pin = event.high_low;
            ncycles = 0;
        } else {
            ncycles++;
        }
    }
}

std::list<struct PinEvent> eventlist_get_interrupt(const uint32_t ncycles) {
    return {
        { .in_n_cycles = ncycles, .high_low = HIGH },
        { .in_n_cycles = 0, .high_low = LOW },
    };
}

void eventlist_push(std::list<struct PinEvent> &eventlist, const std::list<struct PinEvent> &push) {
    eventlist.insert(eventlist.end(), push.cbegin(), push.cend());
}
