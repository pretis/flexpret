#ifndef EMULATOR_CLIENT_COMMON_H
#define EMULATOR_CLIENT_COMMON_H

#include <stdbool.h>
#include <stdint.h>

#define CLIENT_PORT (8080)
#define HIGH (1)
#define LOW  (0)

struct PinEvent {
    uint32_t in_n_cycles;
    bool high_low;
};

int setup_socket(void);

#endif // EMULATOR_CLIENT_COMMON_H
