# Standardized function to check a parameter
function(check_parameter parameter options severity)
  # set_property will only affect cmake GUI users, but we do it for the sake
  # of completeness
  set_property(CACHE ${parameter} PROPERTY STRINGS ${options})

  # Check if parameter is in the recommened/valid list
  list(FIND ${options} ${${parameter}} index)

  # If not found, print out warning/error and recommened/valid options
  if(index EQUAL -1)
    set(msg_part "${parameter} should be one of:\n")

    foreach(option ${${options}})
      string(APPEND msg_part "* ${option}\n")
    endforeach()

    message(${severity} ${msg_part})
  endif()
endfunction()
