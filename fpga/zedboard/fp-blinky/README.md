# FlexPRET blinky

This sample project runs the software application `blinky` on FlexPRET. This does not utilize a bootloader. To build the project, the `blinky` app needs to be compiled. 

## Building

Assuming the FlexPRET build already has been installed to the SDK (see [top-level README.md](../../../README.md) for more information), `blinky` can be compiled with

```
# Step into apps folder
cd $FP_PATH/apps

# Run CMake and compile blinky
cmake -B build && cd build && make blinky
```

With `blinky` built, this project can be built with

```
cd $FP_PATH/build && make fp-fpga-blinky
```

This will take some time. After it has been built, it will automatically attempt to upload the `bitstream.bit` file to the FPGA. To do this step, your computer must be connected to the FPGA.
