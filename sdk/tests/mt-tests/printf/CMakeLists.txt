set(TESTNAME printf-mt)

add_executable(${TESTNAME} printf.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

target_link_libraries(${TESTNAME} fp-sdk)

fp_add_outputs(${TESTNAME})
fp_add_test_runs_to_completion(${TESTNAME})
