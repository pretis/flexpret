# This is the default configuration for FlexPRET
# Feel free to copy this file and create your own
# You can override which configuration file to use either in the top-level 
# CMakeLists.txt or from the command-line when running cmake, like so: TODO:

# Whether to build FlexPRET as an emulation (with Verilator) or for Field-Programmable
# Gated Array (FPGA).
# Allowed options: <verilator/fpga>
set(TARGET "verilator")

# How many hardware threads FlexPRET will be build with
# Allowed range: [1-8]
set(THREADS 1)


set(Flex true)
set(ISPM_KBYTES 64)
set(DSPM_KBYTES 64)
set(MULTIPLIER false)
set(SUFFIX all)
set(CLK_FREQ_MHZ 100)


