set(TESTNAME add-mt)

add_executable(${TESTNAME} add.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

fp_setup_default(${TESTNAME})
fp_add_test_runs_to_completion(${TESTNAME})
