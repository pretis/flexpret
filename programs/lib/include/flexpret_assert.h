#ifndef FLEXPRET_ASSERT_H
#define FLEXPRET_ASSERT_H

#include "flexpret_io.h"
#include <stdbool.h>

/**
 * Important:
 *  To avoid the issue of having the standard library override the assert macro,
 *  we include it here and #undef the macro afterwards. This ensures that when 
 *  other files #include <stdlib.h>, it will not actually be included due to 
 *  header guards, and not override the macro.
 * 
 *  Without having the #include <stdlib.h> here, files that have
 * 
 *  #include <stdlib.h>
 *  #include <flexpret_assert.h>
 * 
 *  will work just fine while files with
 * 
 *  #include <flexpret_assert.h>
 *  #include <stdlib.h>
 * 
 *  will have its assert overridden by the standard library and get compilation
 *  errors.
 * 
 */
#include <stdlib.h>

#undef assert

// NDEBUG is used by the standard library to filter out asserts, so it's a good
// idea to use the same variable
#ifdef NDEBUG
#define assert(cond, reason) ((void)0)
#else
#define assert(cond, reason) do {   \
    if(((cond) == false)) {     \
        _fp_abort(reason);        \
        gpo_write(0,0xFF);  \
        while(true) {}         \
    }                       \
} while(0)
#endif // NDEBUG

#endif