#ifndef LF_TYPES_H
#define LF_TYPES_H

#include <stdint.h>

typedef uint32_t timeout_t;

// Timeout definitions
#define TIMEOUT_FOREVER UINT32_MAX
#define TIMEOUT_NEVER 0
#define NON_BLOCKING 0

// Return types
typedef enum {
    FP_SUCCESS = 0,
    FP_FAILURE = 1,
    FP_TIMEOUT = 2,
    FP_OUT_OF_MEMORY = 3
} fp_ret_t;

#endif