# TODO: Maybe place this in a README instead of a random file
# https://stackoverflow.com/questions/48509911/cmake-add-subdirectory-vs-include

# Build the emulator for FlexPRET
# For some reason, Verilator does not accept command-line arguments in a single
# cmake string
add_custom_target(
    fp-emu ALL
    "verilator" "--cc" "VerilatorTop.v" "--exe" "--trace" "--trace-structs" "--trace-underscore" "--build" "main.cpp" "printf_fsm.c" "pin_event.cpp"
    COMMAND "cp" "${CMAKE_CURRENT_SOURCE_DIR}/obj_dir/VVerilatorTop" "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
    DEPENDS VerilatorTop.v DualPortBram.v
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# Copy generated Chisel top
add_custom_command(
    OUTPUT VerilatorTop.v 
    COMMAND "cp" "${PROJECT_SOURCE_DIR}/build/VerilatorTop.v" "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS FlexPRET
)

# Copy dual port BRAM implemented in raw Verilog
add_custom_command(
    OUTPUT DualPortBram.v
    COMMAND "cp" "${PROJECT_SOURCE_DIR}/src/main/resources/DualPortBramEmulator.v" "${CMAKE_CURRENT_SOURCE_DIR}/DualPortBram.v"
)
