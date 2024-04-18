# Derive other variables from the pure configuration

# Calculate log2(STACKSIZE)
execute_process(
  COMMAND "python3" "-c" "import math; print(int(math.log2(${STACKSIZE})))"
  OUTPUT_VARIABLE STACKSIZE_BITS
)

# For configuration of newlib's reentracy feature; see comments in
# https://github.com/eblot/newlib/blob/master/newlib/libc/include/reent.h
if (${THREADS} GREATER 1)
  set(NEWLIB_REENTRANCY_METHOD __DYNAMIC_REENT__)
else()
  set(NEWLIB_REENTRANCY_METHOD __SINGLE_THREADED__)
endif()
