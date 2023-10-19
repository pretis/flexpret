#ifndef PIN_EVENT_H
#define PIN_EVENT_H

#include <list>
#include <stdint.h>
#include "clients/common.h"

void eventlist_accept_clients(void);
void eventlist_listen(std::list<pin_event_t> &appendto);
void eventlist_set_pin(std::list<pin_event_t> &events, VVerilatorTop *top);

void eventlist_push(std::list<pin_event_t> &eventlist, 
    const std::list<pin_event_t> &push);

std::list<pin_event_t> eventlist_get_interrupt(const uint32_t pin, 
    const uint32_t ncycles);

#endif // PIN_EVENT_H
