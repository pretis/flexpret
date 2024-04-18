# FPGA

FlexPRET may be run on an FPGA. Each supported FPGA board has its own folder. Currently, the only supported board is the *Zedboard*. Refer to the `README.md` there for getting started.

To create an FPGA bitstream, first run `make fpga` in the top-level directory. This will generate an `FpgaTop.v` file based on the Chisel code. The makefile system here will pick up that file.
