# Bootloader

There are a few things to note about the bootloader. 
1. It is compiled to be as little as possible. This means functions like `printf` are not available when bootloading.
2. When the bootloader intializes, you can choose between loading an already integrated application ('static' loading) or loading an application in run-time ('dynamic' loading).
3. The use case of having a bootloader is to be able to easily swap out software running on an FPGA. The idea is that the user can transmit new programs over UART. Without the bootloader, new programs would have to be integrated into an FPGA image, which is very time-consuming.

## Static loading

The bootloader will be compiled with an application placed directly after the bootloader. This is mostly for testing/debugging purposes - if the application is, e.g., `../blinky`, it will be easy to confirm that the bootloader and FPGA is behaving well.

## Dynamic loading

The bootloader can dynamically load an application from UART. This will overwrite the currently loaded application. 

Note that this application MUST be compiled with an offset in its start address, which can be done by setting the `START_ADDR` variable in the makefile equal to the size of the bootloader. One way of doing this is `wc -l bootloader.mem` multiplied with four. This is automated in the `Makefile` in this folder - feel free to see how it's done there.

## Load configuration

Dynamic loading is selected if `(gpi_read_0() & 0b1) == 0b1` evaluates to true - otherwise static loading is selected. The general purpose input pin should be connected to a switch on an FPGA board, so the user can easily configure whether to use static or dynamic loading.

Furthermore, a system-wide reset should be connected to a button. The system-wide reset should reset the entire CPU so it starts at program counter zero and restarts the bootloader.

# Emulating bootloader

To emulate the static bootloader, just run `make clean all run`. Override the variable `APP_NAME` with any other program, like so: `make clean all run APP_NAME=malloc`.

To emulate the dynamic bootloader, the process is a bit more complex and time-consuming. First, compile everything with `make clean all`. Make sure the `bootloader()` function is actually run in the `loader.c` file. 

Next, the application .mem file needs to be serialized. This is automated in the `Makefile`, but can be done manually using the `$(FLEXPRET_ROOT_DIR)/scripts/serialize_app.py` script. It adds data to the application .mem file which concides with the protocol used in the `bootloader()` function.

Finally, run the bootloader with a UART client that transmits the serialized .mem file. This is best done using two terminals. From this folder:

`$(FLEXPRET_ROOT_DIR)/emulator/fp-emu +ispm=bootloader.mem --client`
`$(FLEXPRET_ROOT_DIR)/emulator/clients/build/uart.elf --file app/add.mem.serialized`

This will take a long time. It's a good idea to check the size of the file that is transmitted (`ls -l`) and comment in the printing in the bootloader to view the progress. When it completes you should see some output from your application (if it has any).

Also make sure to turn off the `IMEM store` warning in the `main.cpp` emulator. It is helpful for catching bugs that end up writing to instruction memory, but in this case, that is what we want.
