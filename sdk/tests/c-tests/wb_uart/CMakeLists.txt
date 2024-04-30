set(TESTNAME wb_uart)

add_executable(${TESTNAME} ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

target_link_libraries(${TESTNAME} fp-sdk)
target_compile_definitions(${TESTNAME} PRIVATE NINTERRUPTS=${NINTERRUPTS})

# Change this if you want to try a different file
set(TESTFILE "${CMAKE_CURRENT_SOURCE_DIR}/testfile.txt")

# Generate a header file that contains the initial file in a byte array using
# `xxd`
execute_process(
  COMMAND "xxd" "-i"
  INPUT_FILE "${TESTFILE}"
  OUTPUT_FILE "${CMAKE_CURRENT_SOURCE_DIR}/file.txt.h"
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

fp_add_outputs(${TESTNAME} fp-sdk)

# This client command will transfer the file over UART
# The test then compares the received data with the generated header file from
# earlier
fp_add_test_runs_to_completion_client(
    ${TESTNAME}
    "${FP_EMULATOR_CLIENTS_GENERIC}/uart --file ${TESTFILE}"
)
