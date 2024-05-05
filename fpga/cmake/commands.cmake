if (NOT DEFINED TARGET_NAME)
  message(FATAL_ERROR 
    "TARGET_NAME must be set and define a target before including ${CMAKE_CURRENT_LIST_FILE}"
  )
endif()

math(EXPR CLK_PERIOD_NS "1000 / ${CLK_FREQ_MHZ}" OUTPUT_FORMAT DECIMAL)
math(EXPR CLK_HALF_PERIOD_NS "${CLK_PERIOD_NS} / 2" OUTPUT_FORMAT DECIMAL)

configure_file(
  ${INFILE_LOCATION}/clk_wiz_config.tcl.in 
  ${CMAKE_CURRENT_BINARY_DIR}/tcl/clk_wiz_config.tcl
)

configure_file(
  ${INFILE_LOCATION}/clock.xdc.in
  ${CMAKE_CURRENT_BINARY_DIR}/xdc/clock.xdc
)

configure_file(
  ${INFILE_LOCATION}/set_program_file.tcl.in
  ${CMAKE_CURRENT_BINARY_DIR}/tcl/set_program_file.tcl
)

configure_file(
  ${INFILE_LOCATION}/variables.tcl.in
  ${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl
)

# Make vivado directory for log and journal files
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/vivado)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/rtl)

set(VIVADO_SOURCES
  "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
  "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
  "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
  "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
  "${CMAKE_CURRENT_BINARY_DIR}/xdc/constraints.xdc"
  "${CMAKE_CURRENT_BINARY_DIR}/xdc/clock.xdc"
)

# Add Vivado sources to clean target
set_property(
  TARGET ${TARGET_NAME}
  APPEND PROPERTY
  ADDITIONAL_CLEAN_FILES
    "${CMAKE_CURRENT_BINARY_DIR}/xdc"
    "${CMAKE_CURRENT_BINARY_DIR}/rtl"
    "${CMAKE_CURRENT_BINARY_DIR}/tcl"
    "${CMAKE_CURRENT_BINARY_DIR}/vivado"
)

add_custom_command(
  OUTPUT 
    "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
    "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
  COMMAND bash
    "$ENV{FP_PATH}/cmake/utils/bash/gather_fpga_resources.sh"
    "${CRC32_HASH}"
    "${CMAKE_CURRENT_BINARY_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}"
    "${ISPM_FILE}"
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
  BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
  DEPENDS
    ${SCALA_SOURCES}
  VERBATIM
)

add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
  COMMAND "vivado" 
    "-mode"    "batch" 
    "-journal" "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.jou" 
    "-log"     "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.log"
    "-source"  "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
  DEPENDS
    ${VIVADO_SOURCES}
    "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
)

# Run sbt, which generates Verilog code for the FlexPRET processor
#add_custom_command(
#  OUTPUT "${PROJECT_BINARY_DIR}/FpgaTop.v"
#  COMMAND "sbt" "run fpga h${CRC32_HASH} --no-dedup --target-dir build"
#  DEPENDS ${SCALA_SOURCES}
#  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
#  COMMAND "cp" 
#    ${ISPM_FILE}
#    "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
#  DEPENDS 
#    ${ISPM_FILE}
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
#  COMMAND "cp"
#    "${PROJECT_SOURCE_DIR}/src/main/resources/DualPortBramFPGA.v"
#    "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
#  COMMAND "cp"
#    "${PROJECT_BINARY_DIR}/FpgaTop.v"
#    "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
#  DEPENDS 
#    "${PROJECT_BINARY_DIR}/FpgaTop.v"
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
#  COMMAND "cp"
#    "${CMAKE_CURRENT_SOURCE_DIR}/rtl/Top.v"
#    "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xdc/constraints.xdc"
#  COMMAND "cat"
#    "${CMAKE_CURRENT_BINARY_DIR}/xdc/clock.xdc"  
#    "${CMAKE_CURRENT_SOURCE_DIR}/xdc/Top.xdc"
#    ">"
#    "${CMAKE_CURRENT_BINARY_DIR}/xdc/constraints.xdc"
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
#  COMMAND "cat" 
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
#    "${FP_FPGA_BOARD_PATH}/tcl/setup.tcl"
#    "${FP_FPGA_BOARD_PATH}/tcl/bitstream.tcl" 
#    ">"
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
#  DEPENDS 
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
#    "${CMAKE_CURRENT_BINARY_DIR}/xdc/constraints.xdc"
#)
#
#add_custom_command(
#  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
#  COMMAND "cat" 
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
#    "${FP_FPGA_BOARD_PATH}/tcl/flash.tcl" 
#    ">"
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
#  DEPENDS 
#    "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
#)

# Check whether the `.ispm` file exists or not
# If it does not - let the user know they need to compile it
#add_custom_command(
#  OUTPUT ${ISPM_FILE}
#  COMMAND bash 
#    $ENV{FP_SDK_PATH}/cmake/utils/check_file_exist.sh 
#      ${ISPM_FILE} 
#      "CMake error: Cannot find ${ISPM_FILE} which is required for target"
#  VERBATIM
#)
