if (${TARGET} STREQUAL "fpga")
    set(ISALL ALL)
else()
    set(ISALL EXCLUDE_FROM_ALL)
endif()

add_custom_target(fp-fpga ${ISALL} DEPENDS
    ${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit
)

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

set(BOOTLOADER "${PROJECT_SOURCE_DIR}/apps/build/bootloader/bootloader.mem")
if (NOT EXISTS ${BOOTLOADER})
    message(FATAL_ERROR
    "Could not find ${BOOTLAODER}. Please build the bootloader before proceeding."
    )
endif()

# Make vivado directory for log and journal files
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/vivado)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/rtl)

set(VIVADO_SOURCES
    "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
    "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
    "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
    "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
    "${CMAKE_CURRENT_BINARY_DIR}/xdc/Top.xdc"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/bitstream.bit"
    COMMAND "vivado" 
        "-mode"    "batch" 
        "-journal" "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.jou" 
        "-log"     "${CMAKE_CURRENT_BINARY_DIR}/vivado/vivado.log"
        "-source"  "tcl/bitstream_runnable.tcl"
    DEPENDS
        ${VIVADO_SOURCES}
        "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
    COMMAND "cp" 
        "${PROJECT_SOURCE_DIR}/apps/build/bootloader/bootloader.mem"
        "${CMAKE_CURRENT_BINARY_DIR}/rtl/ispm.mem"
    DEPENDS "${PROJECT_SOURCE_DIR}/apps/build/bootloader/bootloader.mem"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
    COMMAND "cp"
        "${PROJECT_SOURCE_DIR}/src/main/resources/DualPortBramFPGA.v"
        "${CMAKE_CURRENT_BINARY_DIR}/rtl/DualPortBram.v"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
    COMMAND "cp"
        "${PROJECT_BINARY_DIR}/FpgaTop.v"
        "${CMAKE_CURRENT_BINARY_DIR}/rtl/flexpret.v"
    DEPENDS FlexPRET
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
    COMMAND "cp"
        "${CMAKE_CURRENT_SOURCE_DIR}/rtl/Top.v"
        "${CMAKE_CURRENT_BINARY_DIR}/rtl/Top.v"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/xdc/Top.xdc"
    COMMAND "cp"
        "${CMAKE_CURRENT_SOURCE_DIR}/xdc/Top.xdc"
        "${CMAKE_CURRENT_BINARY_DIR}/xdc/Top.xdc"
)

add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
    COMMAND "cat" 
        "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
        "${CMAKE_CURRENT_SOURCE_DIR}/tcl/setup.tcl"
        "${CMAKE_CURRENT_SOURCE_DIR}/tcl/bitstream.tcl" ">"
        "${CMAKE_CURRENT_BINARY_DIR}/tcl/bitstream_runnable.tcl"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl
    COMMAND "cat" 
        "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
        "${CMAKE_CURRENT_SOURCE_DIR}/tcl/flash.tcl" ">"
        "${CMAKE_CURRENT_BINARY_DIR}/tcl/flash_runnable.tcl"
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/tcl/variables.tcl"
)

# TODO: Specify how to make bootloader.mem
