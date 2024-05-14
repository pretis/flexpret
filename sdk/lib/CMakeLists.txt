set(SOURCES
  start.S
  ctx_switch.S
  cond.c
  exceptions.c
  io.c
  lock.c
  pbuf.c
  startup.c
  syscalls.c
  thread.c
  uart.c
  wb.c
)

list(TRANSFORM SOURCES PREPEND "${CMAKE_CURRENT_SOURCE_DIR}/src/")

target_sources(fp-sdk PRIVATE ${SOURCES})

#[[
This is necessary because on the order of which libraries appear on the command
line matters: https://stackoverflow.com/questions/45135/why-does-the-order-in-which-libraries-are-linked-sometimes-cause-errors-in-gcc
Since the printf library depends on printf_putchar and fp-sdk library depends on
the printf library, the simplest solution is to just add printf_putchar.c
to the public interface and recompile it for each appplication.
]]
target_sources(fp-sdk PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/printf_putchar.c)

if (${TARGET} STREQUAL "fpga")
  target_compile_definitions(fp-sdk PUBLIC __FPGA__)
else()
  target_compile_definitions(fp-sdk PUBLIC __EMULATOR__)
endif()

target_compile_definitions(fp-sdk PUBLIC 
  _REENT_SMALL 
  ${NEWLIB_REENTRANCY_METHOD} # Set in configderive.cmake
)

target_include_directories(fp-sdk PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
  "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}>"
  "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)

target_link_options(fp-sdk PUBLIC
  "-L" "${CMAKE_CURRENT_SOURCE_DIR}/linker" "-T" "flexpret.ld"
)
