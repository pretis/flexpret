add_executable(wb_uart_led wb_uart_led.c)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)

target_compile_definitions(wb_uart_led PRIVATE NDEBUG)

fp_setup_default(wb_uart_led fp-sdk-if)

add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)
