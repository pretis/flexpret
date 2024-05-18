# FlexPRET SDK

This directory contains the necessary tools to develop software for FlexPRET. Note that using this SDK requires a FlexPRET hardware installation. Getting one is achieved by building FlexPRET in the top-level directory and installing it here with `make install`. 

There are a number of components to this SDK. The bulk of source code is found in the `./lib` folder, which provides linker scripts and a library for interfacing with FlexPRET. External third-party libraries are found in `./external`. Unit tests are available in `./tests`. Finally, a bootloader can be found in `./bootloader`. 

Refer to the apps folder in the top-level directory (`../apps`) for examples on how to build an application using the SDK. Refer to the unit tests in the `./tests` folder and the apps for examples on how to use the SDK.

## Bootloader

The bootloader is required to quickly transfer new software to FlexPRET when running on an FPGA. Refer to [its docs](./bootloader/README.md) for additional information.

Note that applications that target the FPGA cannot be compiled until the bootloader first has been built. This is because they need to know the size of the bootloader to know how large their offset should be in the compiled executable.

Upon successful build of the bootloader, it will create the file `./lib/linker/bootloader/use/bootloader.ld`, which contains the size of the bootloader.
