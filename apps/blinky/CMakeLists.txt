cmake_minimum_required(VERSION 3.22)

# Set toolchain to RISC-V; must be done before call to project()
include($ENV{FP_SDK_PATH}/cmake/riscv-toolchain.cmake)

project(blinky
  LANGUAGES C
  DESCRIPTION "An application fit for FPGA which blinks LEDs"
  VERSION 1.0.0
)

set(DEBUG true)
set(TARGET "fpga")

add_executable(blinky blinky.c)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)

# Add sdk as subdirectory out-of-tree and link it
add_subdirectory($ENV{FP_SDK_PATH} BINARY_DIR)
target_link_libraries(blinky fp-sdk)

fp_add_outputs(blinky)
