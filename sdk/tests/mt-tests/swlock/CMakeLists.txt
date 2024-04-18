set(TESTNAME swlock)

add_executable(${TESTNAME} ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

fp_setup_default(${TESTNAME})
fp_add_test_runs_to_completion(${TESTNAME})
