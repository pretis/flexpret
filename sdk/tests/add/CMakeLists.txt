add_executable(add add.c)

include(${CMAKE_SOURCE_DIR}/cmake/fp-targets.cmake)


# TODO: Crate "library" so few lines need to be written by each test
set(CMAKE_EXECUTABLE_SUFFIX ".riscv")

target_link_libraries(add printf)
target_link_libraries(add fp-sdk)

fp_add_target_outputs(add)


