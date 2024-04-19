add_executable(wb_uart_led wb_uart_led.c)

# Specific to this application
target_compile_definitions(wb_uart_led PRIVATE NDEBUG)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)
fp_setup_default(wb_uart_led fp-sdk-if)

# Add sdk as subdirectory
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)
