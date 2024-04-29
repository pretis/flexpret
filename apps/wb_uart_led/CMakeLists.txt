add_executable(wb_uart_led wb_uart_led.c)

# Specific to this application
set(DEBUG False)
set(TARGET "fpga")

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)
target_link_libraries(wb_uart_led fp-sdk)

fp_add_outputs(wb_uart_led)
