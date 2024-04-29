cmake_minimum_required(VERSION 3.22)

include($ENV{FP_SDK_PATH}/cmake/riscv-toolchain.cmake)

project(fp-sdk
  DESCRIPTION "Software development kit (SDK) for FlexPRET"
  LANGUAGES C ASM
  VERSION 0.0.1
)

if (NOT DEFINED TARGET)
  set(TARGET "emulator" CACHE STRING "Whether to compile SDK to target FlexPRET on emulator or FPGA" FORCE)
endif()

set(ENVS
  FP_PATH
  FP_SDK_PATH
)

foreach(env ${ENVS})
  if (NOT DEFINED ENV{${env}})
    message(FATAL_ERROR "Environment variable ${env} not set. To fix this\
    step into the top-level directory and `source env.bash` or `source env.fish`.")
  endif()
endforeach()

set(FP_INSTALLED_FILES
  "flexpret/fp-emu"
  "flexpret/hwconfig.cmake"
  "flexpret/hwconfighash.txt"
  "lib/include/flexpret/internal/hwconfig.h"
  "lib/linker/internal/hwconfig.ld"
)

list(TRANSFORM FP_INSTALLED_FILES PREPEND "$ENV{FP_SDK_PATH}/")
foreach(f ${FP_INSTALLED_FILES})
  if (NOT EXISTS ${f})
    message(FATAL_ERROR "Could not find ${f}. Please build FlexPRET and install\
    it to the SDK with `cmake --install` to continue.")
  endif()
endforeach()

include($ENV{FP_SDK_PATH}/flexpret/hwconfig.cmake)
include($ENV{FP_PATH}/cmake/confighash.cmake)
calculate_crc32()

# Make it possible to override which configuration file to use from command line
# Like so: cmake -DCMAKE_CONFIG=my_config --build .
set(CONFIGFILE "$ENV{FP_SDK_PATH}/cmake/configs/default.cmake" CACHE PATH "Which configuration file to select")

include(${CONFIGFILE})
include($ENV{FP_SDK_PATH}/cmake/configverify.cmake)
include($ENV{FP_SDK_PATH}/cmake/configderive.cmake)

configure_file(
  "$ENV{FP_SDK_PATH}/cmake/infiles/swconfig.h.in"
  "$ENV{FP_SDK_PATH}/lib/include/flexpret/internal/swconfig.h"
)

configure_file(
  "$ENV{FP_SDK_PATH}/cmake/infiles/swconfig.ld.in"
  "$ENV{FP_SDK_PATH}/lib/linker/internal/swconfig.ld"
)

# Interface library
add_library(fp-sdk-if INTERFACE)

# Library with source files
# This is the interface library + source code
add_library(fp-sdk INTERFACE)
target_link_libraries(fp-sdk INTERFACE fp-sdk-if)

# Make sdk dependent on these files so it will detect changes to them
target_sources(fp-sdk-if INTERFACE ${FP_INSTALLED_FILES})

if (${TARGET} STREQUAL "fpga")
  option(DEBUG "Enable or disable debug such as printf" OFF)
else()
  option(DEBUG "Enable or disable debug such as printf" ON)
endif()

# TODO: Check if we are missing other options from before
target_compile_options(fp-sdk-if INTERFACE 
  # Gives build-time error if the developer attempts to allocate variables on the
  # stack bigger than the stacksize
  "-Werror=stack-usage=${STACKSIZE}"
  
  # Makes it possible to catch that stack is broken
  "-fstack-protector"

  # Warnings
  "-Wall" "-Wextra"
)


target_compile_definitions(fp-sdk-if INTERFACE 
  FP_CONFIGHASH=0x${CRC32_HASH}
  
  # See configderive.cmake
  ${NEWLIB_REENTRANCY_METHOD}
)

if (NOT ${DEBUG})
  target_compile_definitions(fp-sdk-if INTERFACE NDEBUG)
endif()

add_subdirectory(lib)
add_subdirectory(external)

if (PROJECT_IS_TOP_LEVEL)
  add_subdirectory(bootloader)
  
  include(CTest)
  enable_testing()
  add_subdirectory(tests)
endif()

set_property(
  TARGET fp-sdk-if APPEND PROPERTY
  ADDITIONAL_CLEAN_FILES
    "$ENV{FP_SDK_PATH}/lib/include/flexpret/internal/swconfig.h"
    "$ENV{FP_SDK_PATH}/lib/linker/internal/swconfig.ld"
)