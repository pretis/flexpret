#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

// NDEBUG is used by the standard library to filter out asserts, so it's a good
// idea to use the same variable
#ifdef NDEBUG
#define fp_assert(cond, fmt, ...) ((void) cond)
#else
#define fp_assert(cond, fmt, ...) do { \
    if(((cond) == false)) { \
        _fp_abort(fmt, ## __VA_ARGS__); \
    } \
} while(0)
#endif // NDEBUG

#endif
