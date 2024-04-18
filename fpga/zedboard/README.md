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

Include picture TODO:

## Buttons and LEDs

TODO: References to figure
Feel free to change the top-level FPGA code to your use case. Currently, the center button (ref figure) is used to reset FlexPRET. Use this when you want to re-upload new software. When software is uploaded, the LEDs will "count" upwards, which indicates the progress.

The switch (ref) is used to configure whether the bootloader shall accept an executable or just run whatever is currently at the `APP_LOCATION` address. If you want to re-run software already flashed to the FPGA, set this to zero.

## Software

When compiling software intended to run on the FPGA using the bootloader, the software must be compiled with the `make` variable `TARGET=fpga`. This is because the bootloader is placed in the instruction memory at address zero to `APP_LOCATION`. An application uploaded using the bootloader will be placed from `APP_LOCATION` in instruction memory. Compilation needs to take this into consideration to offset all variables, functions, labels and so on by that amount.

The `make` system has two targets designed specifically for FPGA. `make flash` will automatically upload an application to the FPGA. `make pico` will open `picocom` with the correct configuration - except for which USB the USB-UART dongle is connected to.

The workflow when running software on FPGA FlexPRET looks something like this:
```bash
cd <FlexPRET>/programs/lib/c-tests/wb_uart_led
make clean all flash pico TARGET=fpga
```

The second line will recompile the application (with `TARGET=fpga`), flash it to the FPGA and open `picocom` afterwards.

It is generally recommended to use the `wb_uart_led` application for verifying that FlexPRET on FPGA works. This application awaits data on the UART (which can be transmitted with `make pico` and typing in the terminal) and echoes it back to the user. It also sets the LEDs to whatever data was received.
