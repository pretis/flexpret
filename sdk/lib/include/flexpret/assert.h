#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include <flexpret/io.h>
#include <stdbool.h>

// NDEBUG is used by the standard library to filter out asserts, so it's a good
// idea to use the same variable
#ifdef NDEBUG
// Assert calls shall never have side effects that are necessary for program
// execution: https://barrgroup.com/blog/how-and-when-use-cs-assert-macro
#define fp_assert(cond, fmt, ...) ((void)0)
#else
#define fp_assert(cond, fmt, ...) do { \
    if(((cond) == false)) { \
        _fp_abort(fmt, ## __VA_ARGS__); \
    } \
} while(0)
#endif // NDEBUG

#endif
