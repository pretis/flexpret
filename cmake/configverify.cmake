# The purpose of this file is to check that parameters are within certain bounds
# and let the user know if they have chosen an invalid configuration

# Contains check_parameter function
include(${CMAKE_CURRENT_LIST_DIR}/lib/check.cmake)

# For each parameter set in the configuration, we set a list of possible options
set(THREADS_OPTIONS 1 2 3 4 5 6 7 8)
set(FLEX_OPTIONS true false)
set(ISPM_KBYTES_OPTIONS 16 32 64 96 128 256 512)
set(DSPM_KBYTES_OPTIONS 16 32 64 96 128 256 512)
set(MULTIPLIER_OPTIONS true false)
set(SUFFIX_OPTIONS min ex ti all)
set(CLK_FREQ_MHZ_OPTIONS 50 100)
set(UART_BAUDRATE_OPTIONS 9600 19200 38400 57600 115200) # Potentially more work

# Then we check whether the parameter is any of the possible options
check_parameter(THREADS THREADS_OPTIONS FATAL_ERROR)
check_parameter(FLEX FLEX_OPTIONS FATAL_ERROR)
check_parameter(ISPM_KBYTES ISPM_KBYTES_OPTIONS WARNING)
check_parameter(DSPM_KBYTES DSPM_KBYTES_OPTIONS WARNING)
check_parameter(MULTIPLIER MULTIPLIER_OPTIONS FATAL_ERROR)
check_parameter(SUFFIX SUFFIX_OPTIONS FATAL_ERROR)
check_parameter(CLK_FREQ_MHZ CLK_FREQ_MHZ_OPTIONS WARNING)
check_parameter(UART_BAUDRATE UART_BAUDRATE_OPTIONS WARNING)
