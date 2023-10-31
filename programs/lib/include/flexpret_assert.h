#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

// NDEBUG is used by the standard library to filter out asserts, so it's a good
// idea to use the same variable
#ifdef NDEBUG
#define fp_assert(cond, reason) ((void)0)
#else
#define fp_assert(cond, reason) do {   \
    if(((cond) == false)) {     \
        _fp_abort(reason);        \
        gpo_write(0,0xFF);  \
        while(true) {}         \
    }                       \
} while(0)
#endif // NDEBUG

#endif