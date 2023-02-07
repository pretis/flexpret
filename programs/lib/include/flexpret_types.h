// #include <stdint.h>

typedef uint32_t timeout_t;

// Timeout definitions
#define TIMEOUT_FOREVER UINT32_MAX
#define TIMEOUT_NEVER 0

// Return types
typedef enum {
    FP_SUCCESS = 0,
    FP_FAILIURE = 1,
    FP_TIMEOUT = 2,
    FP_OUT_OF_MEMORY = 3
} fp_ret_t;


