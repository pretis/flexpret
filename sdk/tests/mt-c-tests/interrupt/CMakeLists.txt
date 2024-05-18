set(TESTNAME interrupt-mt)

add_executable(${TESTNAME} ../../c-tests/interrupt/interrupt.c main.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

target_link_libraries(${TESTNAME} fp-sdk)

fp_add_outputs(${TESTNAME})
fp_add_test_runs_to_completion_client(
  ${TESTNAME}
  ${FP_EMULATOR_CLIENTS_GENERIC}/stimuli-mt
)
