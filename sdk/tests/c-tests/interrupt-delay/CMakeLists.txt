set(TESTNAME interrupt-delay)

add_executable(${TESTNAME} ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)
include($ENV{FP_SDK_PATH}/flexpret/hwconfig.cmake)

# Configuration points
set(DELAY_BASE 250)
set(NINTERRUPTS 5)

math(EXPR DELAY "${DELAY_BASE} * ${THREADS}")

target_link_libraries(${TESTNAME} fp-sdk)
target_compile_definitions(${TESTNAME} PRIVATE NINTERRUPTS=${NINTERRUPTS})

fp_add_outputs(${TESTNAME} fp-sdk)

# The test sends NINTERRUPTS interrupts to the program with a certain delay
fp_add_test_runs_to_completion_client(
    ${TESTNAME}
    "${FP_EMULATOR_CLIENTS_GENERIC}/interrupter -a -n ${NINTERRUPTS} -d ${DELAY}"
)
