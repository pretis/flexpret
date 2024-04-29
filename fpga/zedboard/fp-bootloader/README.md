# FlexPRET bootloader

This sample project runs the software application `bootloader` on FlexPRET. This will likely be the most common use-case for running software on your FPGA, because it significantly reduces the time taken to upload new software to the FPGA. Not using the bootloader would require the entire `bitstream.bit` FPGA image to be rebuilt every time new software is uplaoded.

## Building

Assuming the FlexPRET build already has been installed to the SDK (see [top-level README.md](../../../README.md) for more information), `bootloader` can be compiled with

```
# Step into SDK folder
cd $FP_SDK_PATH

# Run CMake and compile bootloader
cmake -B build && cd build && make bootloader
```

With the `bootloader` built, this project can be built with

```
cd $FP_PATH/build && make fp-fpga-bootloader
```

This will take some time. After it has been built, it will automatically attempt to upload the `bitstream.bit` file to the FPGA. To do this step, your computer must be connected to the FPGA.

## Uploading software with bootloader

When compiling a software application that uses the bootloader, the CMake variable `TARGET` must be set to `fpga`. When this is set, the build system will produce a bash script that uploads software using the bootloader. Under the hood, this script uses `serialize_app.py` and `send_uart.py`. See the generated script for more details.
