add_executable(wb_uart_led wb_uart_led.c)

# Specific to this application
set(DEBUG False)
set(TARGET "fpga")

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)
target_link_libraries(wb_uart_led fp-sdk)

# Add sdk as subdirectory
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)

# Must be below add_subdirectory because .riscv extension messes it
fp_setup_default(wb_uart_led)
