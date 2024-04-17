cmake_minimum_required(VERSION 3.22)

project(fp-apps
  LANGUAGES C
  DESCRIPTION "Applications for FlexPRET"
  VERSION 0.0.1
)

include($ENV{FP_SDK_PATH}/build/fp-sdk-import.cmake)

add_subdirectory(bootloader)
#add_subdirectory(wb_uart_led)
