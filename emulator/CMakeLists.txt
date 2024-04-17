if (${TARGET} STREQUAL "verilator")
    set(ISALL ALL)
else()
    set(ISALL EXCLUDE_FROM_ALL)
endif()

add_custom_target(fp-emu ${ISALL} DEPENDS 
    "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
)

# Run Verilator and copy its final executable to the expected location
# For some reason, Verilator does not seem to accept all arguments as a single
# string, so many strings need to be passed instead.
# Also specifying BYPRODUCTS so the `clean` target will automatically delete
# the generated `obj_dir` folder.
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
    COMMAND "verilator" "--cc" "VerilatorTop.v" "--exe" "--trace" "--trace-structs" "--trace-underscore" "--build" "main.cpp" "printf_fsm.c" "pin_event.cpp"
    COMMAND "cp" "${CMAKE_CURRENT_SOURCE_DIR}/obj_dir/VVerilatorTop" "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    BYPRODUCTS ${CMAKE_CURRENT_SOURCE_DIR}/obj_dir
    DEPENDS 
        "${CMAKE_CURRENT_SOURCE_DIR}/VerilatorTop.v" 
        "${CMAKE_CURRENT_SOURCE_DIR}/DualPortBram.v"
)

# Copy generated Chisel top for Verilator to use
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/VerilatorTop.v"
    COMMAND "cp" "${PROJECT_SOURCE_DIR}/build/VerilatorTop.v" "${CMAKE_CURRENT_SOURCE_DIR}"
    DEPENDS FlexPRET
)

# Copy dual port BRAM implemented in raw Verilog for Verilator to use
add_custom_command(
    OUTPUT "${CMAKE_CURRENT_SOURCE_DIR}/DualPortBram.v"
    COMMAND "cp" "${PROJECT_SOURCE_DIR}/src/main/resources/DualPortBramEmulator.v" "${CMAKE_CURRENT_SOURCE_DIR}/DualPortBram.v"
)