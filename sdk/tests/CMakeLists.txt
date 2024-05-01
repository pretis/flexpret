if (NOT ${DEBUG})
  message(FATAL_ERROR 
    "Cannot run tests when printf is disabled because it is used to determine\
    whether the test passes or fails."
  )
endif()

# Printed when application finishes with exit code 0
set(REGEX_PASS_DEFAULT "Finish")

# Printed when application finishes with non-zero exit code
set(REGEX_FAIL_DEFAULT "Abort")

# Run the program and search for "Finish"
function(fp_add_test_runs_to_completion name)
  add_test(
    NAME "${name}_runs_to_completion"
    COMMAND 
      "${CMAKE_SOURCE_DIR}/bin/${name}"
  )
  set_property(
    TEST "${name}_runs_to_completion" 
    PROPERTY PASS_REGULAR_EXPRESSION ${REGEX_PASS_DEFAULT}
  )
  set_property(
    TEST "${name}_runs_to_completion" 
    PROPERTY FAIL_REGULAR_EXPRESSION ${REGEX_FAIL_DEFAULT}
  )
  set_property(
    TEST "${name}_runs_to_completion"
    PROPERTY TIMEOUT 60
  )
endfunction()

# Run the program in the background (&) with an arbitrary command, which typically
# is a client that connects to the emulator and sets FlexPRET's external pins
# (e.g., to generate interrupts or UART signals)
function(fp_add_test_runs_to_completion_client name client_cmd)
  add_test(
    NAME "${name}_runs_to_completion_client"
    COMMAND "bash" "-c"
      "$ENV{FP_SDK_PATH}/bin/${name} --client & sleep 1 && ${client_cmd}"
  )
  set_property(
    TEST "${name}_runs_to_completion_client" 
    PROPERTY PASS_REGULAR_EXPRESSION ${REGEX_PASS_DEFAULT}
  )
  set_property(
    TEST "${name}_runs_to_completion_client" 
    PROPERTY FAIL_REGULAR_EXPRESSION ${REGEX_FAIL_DEFAULT}
  )
  set_property(
    TEST "${name}_runs_to_completion_client"
    PROPERTY TIMEOUT 60
  )
endfunction()

set(FP_EMULATOR_CLIENTS_GENERIC $ENV{FP_PATH}/build/emulator/clients)

add_subdirectory(c-tests)

# Only add multithreaded tests if the number of hardware threads is greater than 1
if (${THREADS} GREATER 1)
  add_subdirectory(mt-c-tests)
endif()
