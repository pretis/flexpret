# We want to include these commands because we do not want to type them out
# for each FPGA project
include(${PROJECT_SOURCE_DIR}/fpga/cmake/commands.cmake)

add_custom_target(fp-fpga-bootloader ${ISALL} DEPENDS
  "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
)
