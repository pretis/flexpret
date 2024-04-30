# Bootloader

There are a few things to note about the bootloader. 
1. It is compiled to be as little as possible. This means functions like `printf` are not available when bootloading.
2. When the bootloader intializes, you can choose between loading an already integrated application ('static' loading) or loading an application in run-time ('dynamic' loading).
3. The use case of having a bootloader is to be able to easily swap out software running on an FPGA. The idea is that the user can transmit new programs over UART. Without the bootloader, new programs would have to be integrated into an FPGA image, which is very time-consuming.

## Static loading

The bootloader will be compiled with an application placed directly after the bootloader. This is mostly for testing/debugging purposes - if the application is, e.g., `blinky`, it will be easy to confirm that the bootloader and FPGA is behaving well.

## Dynamic loading

The bootloader can dynamically load an application from UART. This will overwrite the currently loaded application. Note that this application MUST be compiled with an offset in its start address; this is done automatically when the `TARGET` cmake variable is set to `fpga`. To verify correct bahavior, you may inspect the generated `.dump` file and check that the `_start` function has a non-zero address.

## Load configuration

Dynamic loading is selected if `(gpi_read_0() & 0b1) == 0b1` evaluates to true - otherwise static loading is selected. The general purpose input pin should be connected to a switch on an FPGA board, so the user can easily configure whether to use static or dynamic loading.

Furthermore, a system-wide reset should be connected to a button. The system-wide reset should reset the entire CPU so it starts at program counter zero and restarts the bootloader.

## Once built

Once the bootloader is built, the build system will automatically install a `bootloader.ld` file to the `./lib/linker/bootloader/use` directory. Applications that target FlexPRET on FPGA refuse to build unless this file exists. The reason for this is that the linker script needs to know the application's offset in the instruction memory before it can be linked.

Applications that do not use the bootloader will include `./lib/linker/bootloader/none/bootloder.ld` in its linker script. When using the bootloader the `./lib/linker/bootloader/use/bootloder.ld` file is included instead. (Note the difference in `use` vs. `none` in the paths.)
