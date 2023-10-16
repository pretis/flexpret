#ifndef PIN_EVENT_H
#define PIN_EVENT_H

#include <list>
#include <stdint.h>

struct PinEvent {
    uint32_t in_n_cycles;
    bool high_low;
};

#define HIGH (1)
#define LOW  (0)

void eventlist_accept_clients(void);
void eventlist_listen(std::list<struct PinEvent> &appendto);
void eventlist_set_pin(std::list<struct PinEvent> &events, uint8_t *pin);
void eventlist_push(std::list<struct PinEvent> &eventlist, const std::list<struct PinEvent> &push);
std::list<struct PinEvent> eventlist_get_interrupt(const uint32_t ncycles);

#endif // PIN_EVENT_H
