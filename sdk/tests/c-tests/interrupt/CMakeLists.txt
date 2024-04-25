set(TESTNAME interrupt)

add_executable(${TESTNAME} main.c ${TESTNAME}.c)
include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

target_link_libraries(${TESTNAME} fp-sdk)

fp_add_outputs(${TESTNAME} fp-sdk)
#fp_add_test_runs_to_completion(${TESTNAME})
