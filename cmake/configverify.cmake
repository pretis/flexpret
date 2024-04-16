# set_property will only affect cmake GUI users, but we do it for the sake
# of completeness
# Structure is based on: https://stackoverflow.com/a/39671055/16358883

include(${CMAKE_CURRENT_LIST_DIR}/lib/check.cmake)

set(TARGET_OPTIONS fpga verilator)
set(THREADS_OPTIONS 1 2 3 4 5 6 7 8)
set(FLEX_OPTIONS true false)
set(ISPM_KBYTES_OPTIONS 16 32 64 128 256 512)
set(DSPM_KBYTES_OPTIONS 16 32 64 128 256 512)
set(MULTIPLIER_OPTIONS true false)
set(SUFFIX_OPTIONS min ex ti all)
set(CLK_FREQ_MHZ_OPTIONS 50 100)

check_parameter(TARGET TARGET_OPTIONS FATAL_ERROR)
check_parameter(THREADS THREADS_OPTIONS FATAL_ERROR)
check_parameter(FLEX FLEX_OPTIONS FATAL_ERROR)
check_parameter(ISPM_KBYTES ISPM_KBYTES_OPTIONS WARNING)
check_parameter(DSPM_KBYTES DSPM_KBYTES_OPTIONS WARNING)
check_parameter(MULTIPLIER MULTIPLIER_OPTIONS FATAL_ERROR)
check_parameter(SUFFIX SUFFIX_OPTIONS FATAL_ERROR)
check_parameter(CLK_FREQ_MHZ CLK_FREQ_MHZ_OPTIONS WARNING)
