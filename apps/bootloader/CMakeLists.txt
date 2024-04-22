#[[
We want to place applications right after where the bootloader executable ends.
To do this, the bootloader executable needs to know its own size. We do this by
first compiling the bootloader once to check its size. We then provide that size
to the source code in the second compilation. The size is passed through the
`location.h` file.

There are seveal steps requires to produce the bootloader:
  1. Generate empty location.h
  2. Compile bootloader-first
  3. Generate location.h with size of bootloader-first
  4. Compile bootloader with location.h
  5. Verify size of bootloaders equal and generate bootloader.cmake

bootloader.cmake must be installed to the SDK. This file is required by software
that uses the bootloader.
]]

add_executable(bootloader-first 
  loader/loader.c 
  loader/startup.c
)

add_executable(bootloader
  loader/loader.c 
  loader/startup.c
)



# 1. Empty location.h
add_library(location-empty INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/empty/location.h)
target_include_directories(location-empty INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/empty)

# 2. bootloader-first depends on location-empty
target_link_libraries(bootloader-first location-empty)

# 3. Actual location.h
add_library(location INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/actual/location.h)
target_include_directories(location INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/actual)

# 4. Compile bootloader with location.h
target_link_libraries(bootloader location)

# 5. Verify size and produce bootloader.cmake
add_custom_target(bootloader-verify ALL 
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/bootloader.cmake"
)

# First run of script will generate an empty location.h header file
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/empty/location.h"
  COMMAND "python3" "${CMAKE_CURRENT_SOURCE_DIR}/configure.py" "first"
  COMMENT "Generating empty ${CMAKE_CURRENT_BINARY_DIR}/location.h"
  VERBATIM
)

# Second run of script will generate a location.h header file with the size
# of the bootloader-first.mem, which the actual bootloader needs to know
# to compile
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/actual/location.h"
  COMMAND "python3" "${CMAKE_CURRENT_SOURCE_DIR}/configure.py" "second"
  COMMENT "Generating ${CMAKE_CURRENT_BINARY_DIR}/location.h with size of first bootloader"
  VERBATIM
)

# Third run verifies the size of the bootloaders are equal and produces 
# bootloader.cmake on success
# Bootloader.cmake shall be installed in the SDK
# Software using the bootloader requires this installation
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/bootloader.cmake"
  COMMAND "python3" "${CMAKE_CURRENT_SOURCE_DIR}/configure.py" "third"
  COMMENT "Verifying size of first bootloader vs. actual bootloader. Generates ${CMAKE_CURRENT_BINARY_DIR}/bootloader.cmake on success, which can be installed to SDK."
  VERBATIM
)

set_property(
  TARGET bootloader APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES "location.h"
)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)

target_include_directories(bootloader-first PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(bootloader PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

fp_setup_default(bootloader-first fp-sdk)
fp_setup_default(bootloader fp-sdk)

# Install artifacts
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/bootloader.cmake"
  DESTINATION "$ENV{FP_SDK_PATH}/flexpret"
)
