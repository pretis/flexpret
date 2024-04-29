cmake_minimum_required(VERSION 3.22)

include($ENV{FP_SDK_PATH}/cmake/riscv-toolchain.cmake)

project(fp-apps
  LANGUAGES C ASM
  DESCRIPTION "Applications for FlexPRET"
  VERSION 0.0.1
)

# Add sdk as subdirectory
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)

add_subdirectory(wb_uart_led)
add_subdirectory(blinky)
