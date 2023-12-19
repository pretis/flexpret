# Tests

Tests generally target specific features we need to test, such as system calls or heap allocation. Single-threaded tests are in `c-tests`, multi-threaded tests are in `mt-c-tests`. 

All tests are run with `make clean all`. When new tests are developed, make sure to add them to the list of tests in the `Makefile`, so it is automatically run as well.

## Adding stimuli to pins

The emulator lets you add stimuli to pins (e.g., an interrupt, UART communication) by connecting clients. See `/emulator/clients/README.md` for more information on this feature. This is done by running the `fp-emu` with the `--client` option and running the chosen client afterwards. 

General purpose clients are available in the `/emulator/clients` folder, but a test might need stimuli that is very specific to that test only. In that case, a client can be developed in the same location as the test (see `/programs/tests/c-tests/interrupt` for an example). 

The clients can be run automatically by the build system by setting the `CLIENT` variable to the location of a client. This could either be the path to a client in `/emulator/clients` or any other client. Note that you might need to add a step to compile the client as well, as done in the example.
