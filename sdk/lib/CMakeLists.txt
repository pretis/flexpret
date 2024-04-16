set(SOURCES
  start.S
  ctx_switch.S
  cond.c
  exceptions.c
  lock.c
  printf_putchar.c
  startup.c
  syscalls.c
  thread.c
)

list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/")

target_sources(fp-sdk PRIVATE ${SOURCES})

if (${TARGET} STREQUAL "fpga")
  target_compile_definitions(fp-sdk PUBLIC __FPGA__)
else()
  target_compile_definitions(fp-sdk PUBLIC __EMULATOR__)
endif()


target_include_directories(fp-sdk PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_options(fp-sdk PUBLIC
  "-L" "${CMAKE_CURRENT_SOURCE_DIR}/linker" "-T" "flexpret.ld"
)
