# Emulator clients

The emulator has the `--client` command line option, which will open a incoming socket where a client can connect and send it events to be applied to the pins of the emulated FlexPRET. When the option is selected, the emulator hangs until a client has connected. Without the option selected, the emulator will run as normal.

## How it works

The client transmits one or several `struct PinEvent` which contains information about when an event shall occur on a pin and whether it should be high or low. See the `common.h` header file for more detailed description of each field.

```C
struct PinEvent {
    uint32_t pin;
    uint32_t in_n_cycles;
    bool high_low;
};
```

E.g., setting a pin high and immediately low again can be done by sending two `struct PinEvent` which sets that pin high and low again immediately after. In code, this would be the same as transmitting the pair:

```C
static struct PinEvent interrupt[2] = {
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = HIGH },
    { .pin = PIN_IO_INT_EXTS_0, .in_n_cycles = 0, .high_low = LOW  },
};
```

## Use cases

Below follows some example use cases, highlighting why this server/client architecture is useful.
* Generating interrupts whenever user hits `enter`. This is as simple as transmitting two `struct PinEvent` which sets a pin high and then low.
* Transmitting UART communication based on stdin from user. This includes transmitting 10 `struct PinEvent`; 1 start bit, 8 data bits, 1 stop bit.
* Simulating an Inertial Measurement Unit (IMU) which transmits accelerometer readings over an UART interface.

Note that the server can have several clients connect, making it possible to run both these use cases on different (or same) pins at the same time. This means one could run a test which both transmits UART communication and triggers an interrupt at the same time.

## Adding more clients

Feel free to develop more clients for specific use cases. In that case, create a new file in this folder and make sure to add it to the makefile for compilation. More complex clients might require an improvement of the current build system.

## Compilation

Either compile the clients directly using the Makefile or let them all be compiled together with the emulator.
