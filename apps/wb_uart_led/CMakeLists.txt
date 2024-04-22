add_executable(wb_uart_led wb_uart_led.c)

# Specific to this application
target_compile_definitions(wb_uart_led PRIVATE NDEBUG)

# TODO: Some fundamental changes: Probably need to move bootloader to sdk
# It does not make sense to build it at the same time as an app that requires
# its artifacts 
#set(TARGET "fpga")

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)
fp_setup_default(wb_uart_led fp-sdk)

# Add sdk as subdirectory
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)
