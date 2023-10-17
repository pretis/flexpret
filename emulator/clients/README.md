# Emulator clients

The emulator has the `--client` command line option, which will initialize a server on the client that listens for incoming connections. The clients transmit data to the server with information on how to set external pins. 

## How it works

The client transmits one or several `struct PinEvent` which contains information about when an event shall occur on a pin and whether it should be high or low. E.g., setting a pin high and immediately low again can be done by sending two `struct PinEvent` which sets that pin high and low again immediately after.

## Use cases

Below follows some example use cases, highlighting why this server/client architecture is useful.
* Generating interrupts whenever user hits `enter`. This is as simple as transmitting two `struct PinEvent` which sets a pin high and then low.
* Transmitting UART communication based on stdin from user. This includes transmitting 10 `struct PinEvent`; 1 start bit, 8 data bits, 1 stop bit.

Note that the server can have several clients connect, making it possible to run both these use cases on different (or same) pins at the same time. This means one could run a test which both transmits UART communication and triggers an interrupt at the same time.

## Adding more clients

Feel free to develop more clients for specific use cases. In that case, create a new file in this folder and make sure to add it to the makefile for compilation. More complex clients might require an improvement of the current build system.

## Compilation

Either compile the clients directly using the Makefile or let them all be compiled together with the emulator.
