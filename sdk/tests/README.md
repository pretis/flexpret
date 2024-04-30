# Tests

Tests generally target specific features we need to test, such as system calls or heap allocation. Single-threaded tests are in `c-tests`, multi-threaded tests are in `mt-c-tests`. 

When new tests are developed, make sure to add them to the list of tests in the `CMakeLists.txt`, and call the function `fp_add_test_runs_to_completion` or `fp_add_test_runs_to_completion_client` to register it with CTest.

## Adding stimuli to pins

The emulator lets you add stimuli to pins (e.g., an interrupt, UART communication) by connecting clients. See [emulator client README.md](../../emulator/clients/README.md) for more information on this feature. This is done by running the `fp-emu` with the `--client` option and running the chosen client afterwards. 

General purpose clients are available in the `/emulator/clients` folder, but a test might need stimuli that is very specific to that test only. 

When a client needs to be part of a test, use the `fp_add_test_runs_to_completion_client` and specify the command to run as the second argument to this function. See e.g., [CMakeLists.txt for interrupt.c](./c-tests/interrupt/CMakeLists.txt) or [CMakeLists.txt for interrupt-delay.c](./c-tests/interrupt-delay/CMakeLists.txt) for examples.

You might need to develop your own client for your specific needs.
