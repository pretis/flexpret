#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

#define assert(cond) do {   \
    if(cond == false) {     \
        _fp_abort();        \
    }                       \
} while(0)


#endif