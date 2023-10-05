#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

#undef assert

#define assert(cond, reason) do {   \
    if(((cond) == false)) {     \
        _fp_abort(reason);        \
        gpo_write(0,0xFF);  \
        while(true) {}         \
    }                       \
} while(0)


#endif