# No reason for 3.22 specifically - just the newest version at the time of writing
cmake_minimum_required(VERSION 3.22)

project(FlexPRET 
  DESCRIPTION "FlexPRET - a precision-timed processor designed for mixed-criticality systems"
  VERSION 1.0
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

if (NOT DEFINED FP_CONFIG)
  set(FP_CONFIG "default")
endif()

message(STATUS "Got config ${FP_CONFIG}")

# Make it possible to override which configuration file to use from command line
# Like so: cmake -DFP_CONFIG=my_config -B build
set(CONFIGFILE "${CMAKE_SOURCE_DIR}/cmake/configs/${FP_CONFIG}.cmake" CACHE PATH "Which configuration file to select")

# Sets lots of variables that are used
include(${CONFIGFILE})
include(${CMAKE_SOURCE_DIR}/cmake/configverify.cmake)

#[[
To ensure we catch substantial changes to the configuration, we construct a string
that uniquely represents the configuration. We write it to file and read it on
the next run. If the strings differ, it means the configuration has changed. 

In that case, we need a clean build.
]]
include(${CMAKE_SOURCE_DIR}/cmake/confighash.cmake)

if (EXISTS ${UNIQUE_CONFIG_FILE})
  file(READ ${UNIQUE_CONFIG_FILE} READ_UNIQUE_CONFIG_STRING)
  if (${UNIQUE_CONFIG_STRING} STREQUAL ${READ_UNIQUE_CONFIG_STRING})
    message(STATUS "Using same configuration as last build")
  else()
    message(FATAL_ERROR 
    "Detected change in the configuration from the previous build.\
    You should delete the build folder and run a clean build to get correct\
    results."
    )
  endif()
endif()

#[[
We use the unique configuration string to construct a hash, which becomes
hard-wired into FlexPRET. Since software relies on the config to compile
correctly, we construct another hash known to software. As long as the two
hashes are equal, the configs used are the same.
]]
calculate_crc32()

# Generate configuration files that contain the necessary information about
# hardware
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/infiles/hwconfig.h.in 
  ${CMAKE_BINARY_DIR}/hwconfig.h
)
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/infiles/hwconfig.c.in 
  ${CMAKE_BINARY_DIR}/hwconfig.c
)
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/infiles/hwconfig.ld.in 
  ${CMAKE_BINARY_DIR}/hwconfig.ld
)

# When placed in this location, Scala automatically picks it up
configure_file(
  ${CMAKE_SOURCE_DIR}/cmake/infiles/application.conf.in
  ${CMAKE_SOURCE_DIR}/src/main/resources/application.conf
)

# Adding the Scala sources enabled CMake to check whether they are out-of-date
# or not, meaning FlexPRET is recompiled if changes are made to them
set(SCALA_SOURCES
  "Core/ALU"
  "Core/config"
  "Core/constants"
  "Core/control"
  "Core/core"
  "Core/CSR"
  "Core/Datapath"
  "Core/decode"
  "Core/dspm"
  "Core/instructions"
  "Core/ispm"
  "Core/loadstore"
  "Core/lock"
  "Core/main"
  "Core/MMIO"
  "Core/Multiplier"
  "Core/RegisterFile"
  "Core/scheduler"
  "Core/Top"
  "Core/util"
  "Wishbone/WishboneBus"
  "Wishbone/WishboneMaster"
  "Wishbone/WishboneUart"
)

# Prepend and append the necessary strings to get the full paths
list(TRANSFORM SCALA_SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/main/scala/")
list(TRANSFORM SCALA_SOURCES APPEND ".scala")

add_subdirectory(emulator)
add_subdirectory(fpga)

# TODO: This happens at CMake build time, not at make time
# Always delete previously installed configuration if it exists


#set_property(
#  TARGET emulator APPEND
#  PROPERTY ADDITIONAL_CLEAN_FILES ${UNIQUE_CONFIG_FILE}
#)

file(WRITE "${CMAKE_BINARY_DIR}/hwconfighash.txt" ${CRC32_HASH})

install(FILES
  "${PROJECT_BINARY_DIR}/hwconfig.h"
  DESTINATION "$ENV{FP_SDK_PATH}/lib/include/flexpret/internal"
)

install(FILES
  "${PROJECT_BINARY_DIR}/hwconfig.ld"
  DESTINATION "$ENV{FP_SDK_PATH}/lib/linker/internal"
)

install(FILES
  "${PROJECT_BINARY_DIR}/hwconfighash.txt"
  DESTINATION "$ENV{FP_SDK_PATH}/flexpret"
)

install(FILES "${CONFIGFILE}"
  DESTINATION "$ENV{FP_SDK_PATH}/flexpret"
  RENAME "hwconfig.cmake"
)

install(FILES
  "${PROJECT_BINARY_DIR}/emulator/fp-emu" 
  PERMISSIONS 
    OWNER_EXECUTE 
    OWNER_READ 
    OWNER_WRITE 
    GROUP_READ 
    WORLD_READ
  DESTINATION "$ENV{FP_SDK_PATH}/flexpret"
)
