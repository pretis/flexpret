# No reason for 3.22 specifically - just the newest version at the time of writing
cmake_minimum_required(VERSION 3.22)

project(FlexPRET VERSION 1.0)

# Make it possible to override which configuration file to use from command line
# Like so: cmake --build TODO: Cannot get it to work yet
set(CONFIGFILE "cmake/configs/default.cmake" CACHE PATH "Which configuration file to select")

# Sets lots of variables that are used
include(${CONFIGFILE})
include(${CMAKE_SOURCE_DIR}/cmake/configcheck.cmake)

# Generate configuration files that contain the necessary information about
# hardware
configure_file(cmake/infiles/config.h.in config.h)
configure_file(cmake/infiles/config.ld.in config.ld)

# When placed in this location, Scala automatically picks it up
configure_file(
    cmake/infiles/application.conf.in 
    ${CMAKE_SOURCE_DIR}/src/main/resources/application.conf
)

# Run sbt, which generates Verilog code for the FlexPRET processor
add_custom_target(FlexPRET
    COMMAND "sbt" "run ${TARGET} --no-dedup --target-dir build"
    WORKING_DIRECTORY ".."
)

if (${TARGET} STREQUAL "verilator")
    add_subdirectory(emulator)
elseif (${TARGET} STREQUAL "fpga")
    message(FATAL_ERROR "Detected fpga; not supported yet")
else()
    message(FATAL_ERROR "Target must either be `verilator` or `fpga`.")
endif()
