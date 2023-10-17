#ifndef PIN_EVENT_H
#define PIN_EVENT_H

#include <list>
#include <stdint.h>
#include "clients/common.h"

void eventlist_accept_clients(void);
void eventlist_listen(std::list<struct PinEvent> &appendto);
void eventlist_set_pin(std::list<struct PinEvent> &events, uint8_t *pin);
void eventlist_push(std::list<struct PinEvent> &eventlist, const std::list<struct PinEvent> &push);
std::list<struct PinEvent> eventlist_get_interrupt(const uint32_t ncycles);

#endif // PIN_EVENT_H
