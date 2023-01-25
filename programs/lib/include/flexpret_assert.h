#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

#define ASSERT(cond) do {   \
    if(cond == false) {             \
        _fp_print(666666666); \
        _fp_finish();       \
    }                      \
} while(0)


#endif