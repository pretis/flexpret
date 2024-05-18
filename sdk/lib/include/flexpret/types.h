#ifndef LF_TYPES_H
#define LF_TYPES_H

#include <stdint.h>

typedef uint32_t timeout_t;

// Timeout definitions
#define TIMEOUT_FOREVER UINT32_MAX
#define TIMEOUT_NEVER 0
#define NON_BLOCKING 0

#define UNUSED(x) (void) (x)

#ifdef __TEST__
/**
 * Weak attribute allows other files to override the implementation, which is
 * very useful for testing purposes. This macro can be used to easily mark/unmark
 * functions with the attribute.
 * 
 */
#define FP_TEST_OVERRIDE __attribute__((weak))
#else
#define FP_TEST_OVERRIDE
#endif // __TEST__

// Return types
typedef enum {
    FP_SUCCESS = 0,
    FP_FAILURE = 1,
    FP_TIMEOUT = 2,
    FP_OUT_OF_MEMORY = 3
} fp_ret_t;

/**
 * Use this for initializing arrays with varying size depending on the FP_THREADS
 * macro. Example use case:
 * 
 * static bool need_init[FP_THREADS] = THREAD_ARRAY_INITIALIZER(true);
 * 
 * static uint8_t nbytes_left[FP_THREADS] = THREAD_ARRAY_INITIALIZER(5);
 * 
 */
#if FP_THREADS == 1
    #define THREAD_ARRAY_INITIALIZER(val) { val }
#elif FP_THREADS == 2
    #define THREAD_ARRAY_INITIALIZER(val) { val, val }
#elif FP_THREADS == 3
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val }
#elif FP_THREADS == 4
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val, val }
#elif FP_THREADS == 5
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val, val, val }
#elif FP_THREADS == 6
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val, val, val, val }
#elif FP_THREADS == 7
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val, val, val, val, val }
#elif FP_THREADS == 8
    #define THREAD_ARRAY_INITIALIZER(val) { val, val, val, val, val, val, val, val }
#endif

#endif