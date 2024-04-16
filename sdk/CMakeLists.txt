cmake_minimum_required(VERSION 3.22)

# TODO: Check ENV set

include(${CMAKE_SOURCE_DIR}/cmake/riscv-toolchain.cmake)

project(fp-sdk
  DESCRIPTION "Software development kit (SDK) for FlexPRET"
  LANGUAGES C ASM
  VERSION 0.0.1
)

set(FP_INSTALLED_FILES
  "fp-emu"
  "hwconfig.cmake"
  "hwconfig.h"
  "hwconfig.ld"
  "hwconfighash.txt"
)

list(TRANSFORM FP_INSTALLED_FILES PREPEND "${CMAKE_SOURCE_DIR}/flexpret/")
foreach(f ${FP_INSTALLED_FILES})
  if (NOT EXISTS ${f})
    # TODO: messafge
    message(FATAL_ERROR "Could not find ${f}. Please build FlexPRET and install\
    it here with `cmake --install` to continue.")
  endif()
endforeach()

include(${CMAKE_SOURCE_DIR}/flexpret/hwconfig.cmake)
include($ENV{FP_PATH}/cmake/confighash.cmake)
calculate_crc32()

# Make it possible to override which configuration file to use from command line
# Like so: cmake --build TODO: Cannot get it to work yet
set(CONFIGFILE "${CMAKE_SOURCE_DIR}/cmake/configs/default.cmake" CACHE PATH "Which configuration file to select")

include(${CONFIGFILE})
include(${CMAKE_SOURCE_DIR}/cmake/configverify.cmake)
include(${CMAKE_SOURCE_DIR}/cmake/configderive.cmake)

configure_file(
  "${CMAKE_SOURCE_DIR}/cmake/infiles/swconfig.h.in"
  "${CMAKE_SOURCE_DIR}/lib/include/flexpret/internal/swconfig.h"
)

add_library(fp-sdk STATIC)

# TODO: Check if we are missing other options from before
target_compile_options(fp-sdk PUBLIC 
  # Gives build-time error if the developer attempts to allocate variables on the
  # stack bigger than the stacksize
  "-Werror=stack-usage=${STACKSIZE}"
  
  # Makes it possible to catch that stack is broken
  "-fstack-protector"
)


target_compile_definitions(fp-sdk PUBLIC FP_CONFIGHASH=0x${CRC32_HASH})

add_subdirectory(lib)
add_subdirectory(external)

# TODO: Test framework
if (True)
  add_subdirectory(tests)
endif()
