# No reason for 3.22 specifically - just the newest version at the time of writing
cmake_minimum_required(VERSION 3.22)

project(FlexPRET 
    DESCRIPTION "FlexPRET - a precision-timed processor designed for mixed-criticality systems"
    VERSION 1.0
)

# Make it possible to override which configuration file to use from command line
# Like so: cmake --build TODO: Cannot get it to work yet
set(CONFIGFILE "cmake/configs/default.cmake" CACHE PATH "Which configuration file to select")

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
        message(STATUS 
        "Using same configuration as last build"
        )
    else()
        message(FATAL_ERROR 
        "Detected change in the configuration from the previous build.
        You should delete the build folder and run a clean build to get correct
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
    ${CMAKE_SOURCE_DIR}/cmake/infiles/config.h.in 
    ${CMAKE_BINARY_DIR}/config.h
)
configure_file(
    ${CMAKE_SOURCE_DIR}/cmake/infiles/config.ld.in 
    ${CMAKE_BINARY_DIR}/config.ld
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

# Could perhaps use "${CMAKE_CURRENT_BINARY_DIR}/${TARGET}Top.v"
# but one letter is capitalized. This is a safer and more explicit approach.
if (${TARGET} STREQUAL "verilator")
    set(FP_CHISEL_PRODUCT "${CMAKE_CURRENT_BINARY_DIR}/VerilatorTop.v")
elseif(${TARGET} STREQUAL "fpga")
    set(FP_CHISEL_PRODUCT "${CMAKE_CURRENT_BINARY_DIR}/FpgaTop.v")
else()
    message(FATAL_ERROR "Target must either be `verilator` or `fpga`.")
endif()

# Just adding the command here works, but it will always be considered out-of-date.
# The solution is to use target + command.
# https://stackoverflow.com/questions/48758263/why-is-add-custom-target-always-considered-out-of-date
add_custom_target(FlexPRET DEPENDS ${FP_CHISEL_PRODUCT})

# Run sbt, which generates Verilog code for the FlexPRET processor
add_custom_command(
    OUTPUT ${FP_CHISEL_PRODUCT}
    COMMAND "sbt" "run ${TARGET} h${CRC32_HASH} --no-dedup --target-dir build"
    DEPENDS ${SCALA_SOURCES}
    WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

set_property(
    TARGET FlexPRET APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES
        ${UNIQUE_CONFIG_FILE}
)

file(WRITE "${CMAKE_BINARY_DIR}/confighash.txt" ${CRC32_HASH})

add_subdirectory(emulator)
add_subdirectory(fpga)

install(FILES
    "${PROJECT_BINARY_DIR}/config.h"
    "${PROJECT_BINARY_DIR}/config.ld"
    "${PROJECT_BINARY_DIR}/confighash.txt"
    DESTINATION "${PROJECT_SOURCE_DIR}/sdk/flexpret"
)

install(FILES "${CONFIGFILE}"
    DESTINATION "${PROJECT_SOURCE_DIR}/sdk/flexpret"
    RENAME "hwconfig.cmake"
)

install(FILES
    "${PROJECT_BINARY_DIR}/emulator/fp-emu" PERMISSIONS OWNER_EXECUTE OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
    DESTINATION "${PROJECT_SOURCE_DIR}/sdk/flexpret"
)
