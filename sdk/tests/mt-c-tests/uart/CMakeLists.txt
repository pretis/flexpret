set(TESTNAME uart)

add_executable(${TESTNAME} ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

target_link_libraries(${TESTNAME} fp-sdk)

fp_add_outputs(${TESTNAME} fp-sdk)
fp_add_test_runs_to_completion_client(
  ${TESTNAME}
  "python3 ${CMAKE_CURRENT_SOURCE_DIR}/client/stimuli.py"
)
