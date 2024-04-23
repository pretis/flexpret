set(TESTNAME fib)

add_executable(${TESTNAME} ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

fp_add_outputs(${TESTNAME} fp-sdk)
fp_add_test_runs_to_completion(${TESTNAME})
