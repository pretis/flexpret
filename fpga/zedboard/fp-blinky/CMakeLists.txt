set(TARGET_NAME fp-fpga-blinky)

add_custom_target(${TARGET_NAME} DEPENDS
  COMMAND "vivado" 
    "-mode"    "batch" 
    "-journal" "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.jou" 
    "-log"     "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.log"
    "-source"  "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
  DEPENDS
    "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
    "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
)

set(ISPM_FILE $ENV{FP_PATH}/apps/blinky/build/blinky.mem)

# We want to include these commands because we do not want to type them out
# for each FPGA project
include(${PROJECT_SOURCE_DIR}/fpga/cmake/commands.cmake)
