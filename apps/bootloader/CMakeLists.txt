#[[
We want to place applications right after where the bootloader executable ends.
To do this, the bootloader executable needs to know its own size. We do this by
first compiling the bootloader once to check its size. We then provide that size
to the source code in the second compilation. The size is passed through the
`location.h` file.

TODO: We also verify that the size did not change between the two compilations 
(which might be possible due to unpredictable optimizations).
]]

add_executable(bootloader-first 
    loader/loader.c 
    loader/startup.c
)

add_executable(bootloader
    loader/loader.c 
    loader/startup.c
)

add_library(location INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/location.h)
add_dependencies(bootloader-first location)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/location.h
    # For the first compilation, we leave the file empty. This will set the
    # size to a default value
    COMMAND "echo" "-n" "" > ${CMAKE_CURRENT_BINARY_DIR}/location.h
    VERBATIM
)

add_custom_command(
    TARGET bootloader
    # For the actual compilation, we provide the size of the previous bootloader
    # in `location.h`
    COMMAND "echo" "-n" "#define APP_LOCATION " > ${CMAKE_CURRENT_BINARY_DIR}/location.h
    COMMAND "wc" "-l" "<" "${CMAKE_CURRENT_BINARY_DIR}/bootloader-first.mem" >> ${CMAKE_CURRENT_BINARY_DIR}/location.h
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/bootloader-first.mem"
    VERBATIM
)

set_property(
    TARGET bootloader APPEND
    PROPERTY ADDITIONAL_CLEAN_FILES "location.h"
)

include($ENV{FP_SDK_PATH}/fp-targets.cmake)
include($ENV{FP_SDK_PATH}/riscv-toolchain.cmake)

set(CMAKE_EXECUTABLE_SUFFIX ".riscv")

target_link_libraries(bootloader-first fp-sdk)
target_include_directories(bootloader-first PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
fp_add_extra_outputs(bootloader-first)

target_link_libraries(bootloader fp-sdk)
target_include_directories(bootloader PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
fp_add_extra_outputs(bootloader)
