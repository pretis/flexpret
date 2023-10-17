#ifndef EMULATOR_CLIENT_COMMON_H
#define EMULATOR_CLIENT_COMMON_H

#include <stdbool.h>
#include <stdint.h>

#define CLIENT_PORT (8080)
#define HIGH (1)
#define LOW  (0)

struct PinEvent {
    uint32_t pin;
    uint32_t in_n_cycles;
    bool high_low;
};

#define PIN_IO_INT_EXTS_0 0
#define PIN_IO_INT_EXTS_1 1
#define PIN_IO_INT_EXTS_2 2
#define PIN_IO_INT_EXTS_3 3
#define PIN_IO_INT_EXTS_4 4
#define PIN_IO_INT_EXTS_5 5
#define PIN_IO_INT_EXTS_6 6
#define PIN_IO_INT_EXTS_7 7
// Add more here...

int setup_socket(void);

#endif // EMULATOR_CLIENT_COMMON_H
