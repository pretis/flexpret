cmake_minimum_required(VERSION 3.22)

include(${CMAKE_SOURCE_DIR}/cmake/riscv-toolchain.cmake)

project(fp-sdk
  DESCRIPTION "Software development kit (SDK) for FlexPRET"
  LANGUAGES C ASM
  VERSION 0.0.1
)

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

list(TRANSFORM FP_INSTALLED_FILES PREPEND "${CMAKE_SOURCE_DIR}/")
foreach(f ${FP_INSTALLED_FILES})
  if (NOT EXISTS ${f})
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

configure_file(
  "${CMAKE_SOURCE_DIR}/cmake/infiles/swconfig.ld.in"
  "${CMAKE_SOURCE_DIR}/lib/linker/internal/swconfig.ld"
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


set_property(
  TARGET ${PROJECT_NAME} APPEND PROPERTY
  ADDITIONAL_CLEAN_FILES
    "${CMAKE_SOURCE_DIR}/lib/include/flexpret/internal/swconfig.h"
    "${CMAKE_SOURCE_DIR}/lib/linker/internal/swconfig.ld"
)