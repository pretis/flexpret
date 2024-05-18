# Table of Contents

- [Table of Contents](#table-of-contents)
- [Getting started](#getting-started)
- [Hardware description](#hardware-description)
  - [Prerequisites](#prerequisites)
  - [Physical setup](#physical-setup)
  - [Software](#software)

# Getting started

There are a number of additional steps required to run FlexPRET on an FPGA as opposed to emulating it. It is recommended to upload the bitstreams from three projects to the FPGA, each with increasing order of complexity. This way, if something fails, it will be easier to know what was wrong. 

1. The project with the lowest order of complexity is a bistream that just lights up four LEDs on the Zedboard. If this works, it verifies that there are no issues uploading bitstreams to the Zedboard. Instructions on how to do this is found inside `./zedboard/leds`. This example does not involve FlexPRET.
2. The next project should be FlexPRET running very simple software, just blinking some LEDs. The example is found inside `./zedboard/fp-blinky`.
3. The final project is the one that will be used almost exclusively. It has FlexPRET that runs a bootloader (`../programs/lib/tests/c-tests/bootloader`), which makes it possible to upload new software without uploading another bitstream. The project is located in `./zedboard/fp-bootloader`.

# Hardware description

## Prerequisites

1. The [Zedboard FPGA](https://digilent.com/shop/zedboard-zynq-7000-arm-fpga-soc-development-board/). If you have another FPGA, you should instead create another directory for that FPGA and add support for it. There is probably a lot of code that can be copied.
2. Vivado for generating bitstream for Zedboard. Other tools might be used, but those are not supported at the time of writing.
3. Power supply for FPGA - probably comes when bought.
4. Micro-USB cable for uploading bitstreams from computer to FPGA.
5. A USB-UART dongle for standard input/output and uploading new software using bootloader.

## Physical setup

Figure 1 shows the physical setup for the Zedboard. The figure is annotated with important areas.
1. The leftmost cable connection gives power to the Zedboard. The switch underneath the connector must be flipped to the left to turn on power to the Zedboard. The rightmost connection is a micro-USB cable from your computer to the zedboard, used to upload bitstreams.
2. In the `fp-bootloader` example, we use this connector to interface with FlexPRET's UART device - which in turn is used to upload new software to the bootloader. Currently, JA1 is FlexPRET's UART TX and JA2 is FlexPRET's UART RX. To add custom pins, consult the `.xdc` files and make corresponding changes to your `Top.v`.
3. The rightmost switch (SW0) is used to configure whether the bootloader shall await a new program or run the one currently located in its instruction memory.
4. The center button (BTNC) resets FlexPRET. This includes setting its program counter back to zero, which means FlexPRET will return to it's bootloader. 

![Zedboard physical setup](./docs/zedboard-setup.png)

Note that you might need to push the reset button several times to reset the system. The reason for this is currently not known, but it likely has something to do with how the reset signal propagates inside of FlexPRET.

If attempting to reset several times still does not work, we recommend flashing the bitstream again. 

## Software

When compiling software intended to run on the FPGA using the bootloader, the software must be compiled with the CMake variable `TARGET` to fpga. This is because the bootloader is placed in the instruction memory at address zero to `APP_LOCATION`. An application uploaded using the bootloader will be placed from `APP_LOCATION` in instruction memory. Compilation needs to take this into consideration to offset all variables, functions, labels and so on by that amount.

When the `TARGET` variable is set to fpga, the build system will generate a script to flash the application's `.mem` file to the FPGA (instead of running it on the emulator).
