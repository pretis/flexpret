cmake_minimum_required(VERSION 3.22)

# Set toolchain to RISC-V; must be done before call to project()
include($ENV{FP_SDK_PATH}/cmake/riscv-toolchain.cmake)

project(wb_uart_led
  LANGUAGES C
  DESCRIPTION "An application fit for FPGA which sets LEDs and prints UART input back to user"
  VERSION 1.0.0
)

add_executable(wb_uart_led wb_uart_led.c)

# Specific to this application
set(DEBUG False)
set(TARGET "fpga")

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)

# Add sdk as subdirectory out-of-tree and link it
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)
target_link_libraries(wb_uart_led fp-sdk)

fp_add_outputs(wb_uart_led)
