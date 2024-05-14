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
  5. Verify size of bootloaders equal and generate bootloader.ld

bootloader.ld must be installed to the SDK. This file is required by software
that uses the bootloader.
]]

add_executable(bootloader-first 
  loader.c 
  startup.c
)

add_executable(bootloader-second
  loader.c 
  startup.c
)

# 1. Empty location.h
add_library(location-empty INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/empty/location.h)
target_include_directories(location-empty INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/empty)

# 2. bootloader-first depends on location-empty
target_link_libraries(bootloader-first PRIVATE location-empty)

# 3. Actual location.h
add_library(location INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/actual/location.h)
target_include_directories(location INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/actual)
add_dependencies(location bootloader-first)

# 4. Compile bootloader with location.h
target_link_libraries(bootloader-second PRIVATE location)

# 5. Verify size and produce bootloader.ld
# Note: Need to call this target `bootloader` so this target (and its dependencies)
#       get run if the user writes `make bootloader`. If e.g., `bootloader-second`
#       was named `bootloader`, then `make bootloader` would not produce 
#       `bootloader.ld`.
add_custom_target(bootloader ALL 
  DEPENDS "$ENV{FP_SDK_PATH}/lib/linker/bootloader/use/bootloader.ld"
)

# Rename everything from bootloader-second.* to bootloader.*
add_custom_command(
  TARGET bootloader POST_BUILD
  COMMAND "mv"
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader-second.map
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.map
  COMMAND "mv"
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader-second.dump
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.dump
  COMMAND "mv"
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader-second.mem
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.mem
  COMMAND "mv"
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader-second.mem.orig
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.mem.orig
  COMMAND "mv"
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader-second
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader
)

# Add the renamed files to clean target
set_property(TARGET bootloader APPEND PROPERTY
  ADDITIONAL_CLEAN_FILES
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.map
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.dump
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.mem
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader.mem.orig
    ${CMAKE_CURRENT_BINARY_DIR}/bootloader
)

add_dependencies(bootloader bootloader-second)

target_compile_definitions(bootloader-first PRIVATE NDEBUG)
target_compile_definitions(bootloader-second PRIVATE NDEBUG)

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
# bootloader.ld on success
# Bootloader.ld shall be installed in the SDK
# Software using the bootloader requires this installation
add_custom_command(
  OUTPUT "$ENV{FP_SDK_PATH}/lib/linker/bootloader/use/bootloader.ld"
  COMMAND "python3" "${CMAKE_CURRENT_SOURCE_DIR}/configure.py" "third"
  COMMENT "Verifying size of first bootloader vs. actual bootloader. Generates $ENV{FP_SDK_PATH}/lib/linker/bootloader/use/bootloader.ld on success."
  VERBATIM
)

set_property(
  TARGET bootloader APPEND
  PROPERTY ADDITIONAL_CLEAN_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/actual/location.h"
    "$ENV{FP_SDK_PATH}/flexpret/lib/linker/bootloader/use/bootloader.ld"
)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)

target_include_directories(bootloader-first PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
target_include_directories(bootloader-second PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(bootloader-first PUBLIC fp-sdk)
target_link_libraries(bootloader-second PUBLIC fp-sdk)

fp_add_outputs(bootloader-first)

# We renamed `bootloader-second` to `bootloader`, so `fp_add_outputs` won't work. 
# Instead we just do everything that function does manually

# Generate .dump file
fp_add_dump_output(bootloader-second)
fp_add_mem_output(bootloader-second)
fp_add_map_output(bootloader-second)
fp_print_memory_usage(bootloader-second)

# Create bash script
set(IMEM_LOCATION ${CMAKE_CURRENT_BINARY_DIR})
set(IMEM_NAME bootloader.mem)
set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/emu-app.sh.in)
configure_file(
  ${INFILE}
  ${CMAKE_SOURCE_DIR}/bin/bootloader
  FILE_PERMISSIONS 
    OWNER_EXECUTE # Need execute, the others are normal permissions
    OWNER_READ 
    OWNER_WRITE 
    GROUP_READ 
    WORLD_READ
  @ONLY
)
set_property(
  TARGET ${target} APPEND PROPERTY
  ADDITIONAL_CLEAN_FILES
    ${CMAKE_SOURCE_DIR}/bin
)

set(LINKER_INCLUDE "$ENV{FP_SDK_PATH}/lib/linker/bootloader/none")

target_link_options(bootloader-second PRIVATE "-Wl,-L" ${LINKER_INCLUDE})
