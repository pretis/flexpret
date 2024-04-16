cmake_minimum_required(VERSION 3.22)

# TODO: Check ENV set

include(${CMAKE_SOURCE_DIR}/cmake/riscv-toolchain.cmake)

project(fp-sdk
  DESCRIPTION "Software development kit (SDK) for FlexPRET"
  LANGUAGES C ASM
)

set(FP_INSTALLED_FILES
  "config.h"
  "config.ld"
  "confighash.txt"
  "fp-emu"
  "hwconfig.cmake"
)

list(TRANSFORM FP_INSTALLED_FILES PREPEND "${CMAKE_SOURCE_DIR}/flexpret/")
foreach(f ${FP_INSTALLED_FILES})
  if (NOT EXISTS ${f})
    # TODO: messafge
    message(FATAL_ERROR "fatak ${f}")
  endif()
endforeach()

include(${CMAKE_SOURCE_DIR}/flexpret/hwconfig.cmake)
include($ENV{FP_PATH}/cmake/confighash.cmake)
calculate_crc32()


# TODO: swconfig.cmake
set(STACKSIZE 4096)
set(STACKSIZE_BITS 11) # TODO: calcualte it

# TODO: Set -Werror-stack-usage

configure_file(
  "${CMAKE_SOURCE_DIR}/cmake/infiles/swconfig.h.in"
  "${CMAKE_SOURCE_DIR}/lib/include/flexpret/internal/swconfig.h"
)

add_library(fp-sdk STATIC)

target_compile_definitions(fp-sdk PUBLIC FP_CONFIGHASH=${CRC32_HASH})



add_subdirectory(external)
add_subdirectory(lib)


#TODO: define __emulator__/__fpga__

# TODO: Set printf_=printf ...