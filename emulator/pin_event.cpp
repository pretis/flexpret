/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief The code implements a simple API for setting pins through an external
 * socket connection.
 * 
 * When a `pinevent_t` is received, the pin number is used as an index into the 
 * state_t array and added to the list. When the eventlist_set_pin function is 
 * called, it checks the list. If an event is found, the ncycles variable starts 
 * counting until the in_n_cycles limit is reached. Once the limit is reached,
 * the event triggers and the event itself is popped from the list.
 * 
 */

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

#include "../build/hwconfig.h"

#define NUM_GPI (4)
#define FP_MAX_THREADS (8)
#define NUM_PINS (FP_MAX_THREADS + (NUM_GPI * 32) + 2)

typedef struct {
    uint64_t ncycles;
    std::list<pin_event_t> eventlist;
} state_t;

/**
 * Each pin needs its own state (ncycles + eventlist).
 * 
 * Note: The #defines in clients/common.h are used as indecies to this array.
 * 
 */
static state_t pinstates[NUM_PINS];
static int new_socket = 0;

static inline void set_pin(uint32_t which_pin, VVerilatorTop *top, uint8_t val)
{
    if (PIN_IO_GPI_0(0) <= which_pin && which_pin < PIN_IO_GPI_0(GPI_PORT_SIZE)) {
        uint32_t mask = (1 << (which_pin - PIN_IO_GPI_0(0)));
        if (val == HIGH) {
            top->io_gpio_in_0 |= mask;
        } else {
            top->io_gpio_in_0 &= ~mask;
        }
    } else if (PIN_IO_GPI_1(0) <= which_pin && which_pin < PIN_IO_GPI_1(GPI_PORT_SIZE)) {
        uint32_t mask = (1 << (which_pin - PIN_IO_GPI_1(0)));
        if (val == HIGH) {
            top->io_gpio_in_1 |= mask;
        } else {
            top->io_gpio_in_1 &= ~mask;
        }
    } else if (PIN_IO_GPI_2(0) <= which_pin && which_pin < PIN_IO_GPI_2(GPI_PORT_SIZE)) {
        uint32_t mask = (1 << (which_pin - PIN_IO_GPI_2(0)));
        if (val == HIGH) {
            top->io_gpio_in_2 |= mask;
        } else {
            top->io_gpio_in_2 &= ~mask;
        }
    } else if (PIN_IO_GPI_3(0) <= which_pin && which_pin < PIN_IO_GPI_3(GPI_PORT_SIZE)) {
        uint32_t mask = (1 << (which_pin - PIN_IO_GPI_3(0)));
        if (val == HIGH) {
            top->io_gpio_in_3 |= mask;
        } else {
            top->io_gpio_in_3 &= ~mask;
        }
    }
    switch (which_pin)
    {
#if FP_THREADS >= 1
    case PIN_IO_INT_EXTS_0: top->io_int_exts_0 = val; break;
#endif
#if FP_THREADS >= 2
    case PIN_IO_INT_EXTS_1: top->io_int_exts_1 = val; break;
#endif
#if FP_THREADS >= 3
    case PIN_IO_INT_EXTS_2: top->io_int_exts_2 = val; break;
#endif
#if FP_THREADS >= 4
    case PIN_IO_INT_EXTS_3: top->io_int_exts_3 = val; break;
#endif
#if FP_THREADS >= 5
    case PIN_IO_INT_EXTS_4: top->io_int_exts_4 = val; break;
#endif
#if FP_THREADS >= 6
    case PIN_IO_INT_EXTS_5: top->io_int_exts_5 = val; break;
#endif
#if FP_THREADS >= 7
    case PIN_IO_INT_EXTS_6: top->io_int_exts_6 = val; break;
#endif
#if FP_THREADS >= 8
    case PIN_IO_INT_EXTS_7: top->io_int_exts_7 = val; break;
#endif

    case PIN_IO_UART_RX: top->io_uart_rx = val; break;
    default:
        break;
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

void eventlist_listen(void) {
    static pin_event_t events[128];
    int bytes_read = read(new_socket, events, sizeof(events));
    if (bytes_read <= 0) {
        return;
    } else {
        int nevents = bytes_read / sizeof(pin_event_t);
        for (int i = 0; i < nevents; i++) {
            pin_event_t event = events[i];

            // Push the event to the correct list; which one to use is given
            // by the event.pin
            assert(event.pin < NUM_PINS);
            pinstates[event.pin].eventlist.push_back(event);
        }
    }
}

void eventlist_set_pin(VVerilatorTop *top) {
    for (int i = 0; i < NUM_PINS; i++) {
        state_t state = pinstates[i];
        if (!state.eventlist.empty()) {
            pin_event_t event = state.eventlist.front();
            if (event.in_n_cycles == state.ncycles) {
#if 0
                printf("event occur on pin %i, @ %li cycles: %s\n", event.pin,
                    state.ncycles, event.high_low == HIGH ? "high" : "low");
#endif 
                state.eventlist.pop_front();
                set_pin(event.pin, top, event.high_low);
                state.ncycles = 0;
            } else {
                state.ncycles++;
            }
        }
        pinstates[i] = state;
    }
}
