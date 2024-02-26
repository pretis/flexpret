#ifndef PIN_EVENT_H
#define PIN_EVENT_H

#include <stdint.h>
#include "clients/common.h"

void eventlist_accept_clients(void);
void eventlist_listen(void);
void eventlist_set_pin(VVerilatorTop *top);

#endif // PIN_EVENT_H
