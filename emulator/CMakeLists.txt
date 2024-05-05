add_custom_target(emulator ALL 
  DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/fp-emu
)

set(EMULATOR_SOURCES
  "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp"
  "${CMAKE_CURRENT_SOURCE_DIR}/printf_fsm.c"
  "${CMAKE_CURRENT_SOURCE_DIR}/pin_event.cpp"
  "${CMAKE_BINARY_DIR}/hwconfig.c"
)

add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
  COMMAND bash 
    "$ENV{FP_PATH}/cmake/utils/bash/build_fp_emu.sh"
    "${CRC32_HASH}"
    ${EMULATOR_SOURCES}
  WORKING_DIRECTORY 
    ${PROJECT_SOURCE_DIR}
  BYPRODUCTS
    "${CMAKE_CURRENT_BINARY_DIR}/VerilatorTop.v"
    "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
    "${CMAKE_CURRENT_BINARY_DIR}/obj_dir"
  DEPENDS
    ${SCALA_SOURCES}
  VERBATIM
)

add_subdirectory(clients)
