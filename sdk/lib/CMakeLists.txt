add_library(
  fp-lib
)

set(SOURCES
  start.s
  ctx_switch.s
  cond.c
  exceptions.c
  lock.c
  printf_putchar.c
  startup.c
  syscalls.c
  thread.c
)

list(TRANSFORM .. "${CMAKE_CURRENT_SOURCE_DIR}/src/")


