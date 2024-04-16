add_executable(add add.c)

include(${CMAKE_SOURCE_DIR}/cmake/fp-targets.cmake)

target_link_libraries(add fp-sdk)
