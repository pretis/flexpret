# We want to include these commands because we do not want to type them out
# for each FPGA project
include(${PROJECT_SOURCE_DIR}/fpga/cmake/commands.cmake)

add_custom_target(fp-fpga-bootloader DEPENDS
  "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
)

add_custom_target(fp-fpga-bootloader-flash
  COMMAND "vivado" 
    "-mode"    "batch" 
    "-journal" "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.jou" 
    "-log"     "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.log"
    "-source"  "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
  DEPENDS
    "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
    "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
)
