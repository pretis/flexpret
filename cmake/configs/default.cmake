# This is the default configuration for FlexPRET
# Feel free to copy this file and create your own
# You can override which configuration file to use either in the top-level 
# CMakeLists.txt or from the command-line when running cmake, like so:
# Like so: cmake -DCMAKE_CONFIG=my_config --build .

# See `../configverify.cmake` for valid options for each configuration parameter

# Note: Using CACHE with FORCE everywhere does not really make sense, but it is
# advantageous to connect a description to the variable instead of a comment

# Valid: [1-8]
set(THREADS 4 CACHE STRING "How many hardware threads to build FlexPRET with" FORCE)

# Valid: <true/false>
set(FLEX true CACHE BOOL "Whether to compile FlexPRET with flexible hardware sheduler" FORCE)

# Valid: Any power of 2, but should fit in FPGA
set(ISPM_KBYTES 64 CACHE STRING "Size of the intruction scratchpad memmory (kB)" FORCE)

# Valid: Any power of 2, but should fit in FPGA
set(DSPM_KBYTES 64 CACHE STRING "Size of the data scratchpad memmory (kB)" FORCE)

# Valid: <true/false>
set(MULTIPLIER false CACHE BOOL "Whether to use a multiplier in FlexPRET (currently not used)" FORCE)

# Valid: <min/ex/ti/all>:
# 	min: base RV32I
# 	ex: min+exceptions (necessary)
# 	ti: ex+timing instructions
# 	all: ti+ all exception causes and stats
set(SUFFIX all CACHE STRING "Features enabled. min -> base RV32I, ex -> min + exceptions (necessary), ti -> ex + timing instructions, all -> ti + all exception causes and status" FORCE)

# Valid: <50/100> (and probably more, but these have been tested)
set(CLK_FREQ_MHZ 100 CACHE STRING "Requested clock frequency in MHz" FORCE)

# Valid: <9600, 19200,38400, 57600, 115200> (potentially more)
set(UART_BAUDRATE 115200 CACHE STRING "Requested UART baudrate in Hz" FORCE)
