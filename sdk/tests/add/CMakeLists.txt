add_executable(add add.c)

include(${CMAKE_SOURCE_DIR}/cmake/fp-app.cmake)

fp_setup_default(add)

