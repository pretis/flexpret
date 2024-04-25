add_custom_target(fp-emu ALL DEPENDS 
  "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
)

add_subdirectory(clients)

# Run Verilator and copy its final executable to the expected location
# For some reason, Verilator does not seem to accept all arguments as a single
# string, so many strings need to be passed instead.
# Also specifying BYPRODUCTS so the `clean` target will automatically delete
# the generated `obj_dir` folder.
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
  COMMAND "verilator" 
    "--cc" "${CMAKE_CURRENT_BINARY_DIR}/VerilatorTop.v"
    "--exe" 
    "--trace" 
    "--trace-structs" 
    "--trace-underscore" 
    "--build" 
      "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp" 
      "${CMAKE_CURRENT_SOURCE_DIR}/printf_fsm.c" 
      "${CMAKE_CURRENT_SOURCE_DIR}/pin_event.cpp"
  COMMAND "cp" 
    "${CMAKE_CURRENT_BINARY_DIR}/obj_dir/VVerilatorTop" 
    "${CMAKE_CURRENT_BINARY_DIR}/fp-emu"
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/obj_dir"
  DEPENDS 
    "${CMAKE_CURRENT_BINARY_DIR}/VerilatorTop.v" 
    "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
)

# Run sbt, which generates Verilog code for the FlexPRET processor
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/VerilatorTop.v"
  COMMAND "sbt" "run verilator h${CRC32_HASH} --no-dedup --target-dir build/emulator"
  DEPENDS ${SCALA_SOURCES}
  WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

# Copy dual port BRAM implemented in raw Verilog for Verilator to use
add_custom_command(
  OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
  BYPRODUCTS "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
  COMMAND "cp" 
    "${PROJECT_SOURCE_DIR}/src/main/resources/DualPortBramEmulator.v" 
    "${CMAKE_CURRENT_BINARY_DIR}/DualPortBram.v"
)
