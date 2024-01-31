#ifndef EMULATOR_CLIENT_COMMON_H
#define EMULATOR_CLIENT_COMMON_H

#include <stdbool.h>
#include <stdint.h>

#define CLIENT_PORT (8080)
#define HIGH (1)
#define LOW  (0)

typedef struct {
    /**
     * Which pin the event occurs on; this number is determined by the macros 
     * found below.
     * 
     */
    uint32_t pin;

    /**
     * The number of cycles until the event should occur relative to the time
     * of the last PinEvent in the list of pending events.
     * 
     * E.g., if the list already contains three events like this:
     * 
     *  { 
     *      { .pin = MY_PIN, .in_n_cycles = 300, .high_low = HIGH },
     *      { .pin = MY_PIN, .in_n_cycles = 500, .high_low = LOW  },
     *      { .pin = MY_PIN, .in_n_cycles = 250, .high_low = HIGH },
     *  };
     * 
     * when the emulator receives the list it will start counting. When it hits
     * 300 it will trigger the first event and restart the counter. When it hits
     * 500 it will trigger the second event and restart the counter. And so on.
     * 
     */
    uint32_t in_n_cycles;

    /**
     * Whether to set the pin HIGH (1) or LOW (0).
     * 
     */
    bool high_low;
} pin_event_t;

#define PIN_IO_INT_EXTS_0 0
#define PIN_IO_INT_EXTS_1 1
#define PIN_IO_INT_EXTS_2 2
#define PIN_IO_INT_EXTS_3 3
#define PIN_IO_INT_EXTS_4 4
#define PIN_IO_INT_EXTS_5 5
#define PIN_IO_INT_EXTS_6 6
#define PIN_IO_INT_EXTS_7 7

// Each GPI_x has 32 pins
#define PIN_IO_GPI_0(pin) (pin + 8)
#define PIN_IO_GPI_1(pin) (pin + 40)
#define PIN_IO_GPI_2(pin) (pin + 72)
#define PIN_IO_GPI_3(pin) (pin + 104)

#define PIN_IO_UART_RX (136)
#define PIN_IO_UART_TX (137)


// Add more here...

int setup_socket(void);

#endif // EMULATOR_CLIENT_COMMON_H
