set(SOURCES
  start.S
  ctx_switch.S
  cond.c
  exceptions.c
  io.c
  lock.c
  pbuf.c
  printf_putchar.c
  sdd_uart.c
  startup.c
  syscalls.c
  thread.c
  uart.c
  wb.c
)

list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/")

target_sources(fp-sdk PUBLIC ${SOURCES})

if (${TARGET} STREQUAL "fpga")
  target_compile_definitions(fp-sdk-if INTERFACE __FPGA__)
else()
  target_compile_definitions(fp-sdk-if INTERFACE __EMULATOR__)
endif()

target_compile_definitions(fp-sdk-if INTERFACE 
  _REENT_SMALL 
  ${NEWLIB_REENTRANCY_METHOD} # Set in configderive.cmake
)

target_include_directories(fp-sdk-if INTERFACE
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
  "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

target_link_options(fp-sdk-if INTERFACE
  "-L" "${CMAKE_CURRENT_SOURCE_DIR}/linker" "-T" "flexpret.ld"
)
