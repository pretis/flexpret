if (NOT printf IN_LIST EXTERNAL_LIBS_USED)
  message(FATAL_ERROR 
    "Cannot run tests when printf is disabled because it is used to determine\
    whether the test passes or fails."
  )
endif()

# Printed when application finishes with exit code 0
set(REGEX_PASS_DEFAULT "Finish")

# Printed when application finishes with non-zero exit code
set(REGEX_FAIL_DEFAULT "Abort")

function(fp_add_test_runs_to_completion name)
  add_test(
    NAME "${name}_runs_to_completion"
    COMMAND "${CMAKE_SOURCE_DIR}/flexpret/fp-emu" "+ispm=${name}.mem"
  )
  set_property(
    TEST "${name}_runs_to_completion" 
    PROPERTY PASS_REGULAR_EXPRESSION ${REGEX_PASS_DEFAULT}
  )
  set_property(
    TEST "${name}_runs_to_completion" 
    PROPERTY FAIL_REGULAR_EXPRESSION ${REGEX_FAIL_DEFAULT}
  )
endfunction()

add_subdirectory(add)
add_subdirectory(calloc)
add_subdirectory(fib)
add_subdirectory(global)
#add_subdirectory(gpio)
add_subdirectory(hwlock)
#add_subdirectory(interrupt)
#add_subdirectory(interrupt-delay)
add_subdirectory(lbu)
add_subdirectory(malloc)
add_subdirectory(realloc)
add_subdirectory(sections)
add_subdirectory(syscall)
add_subdirectory(time)
