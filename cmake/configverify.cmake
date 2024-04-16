# set_property will only affect cmake GUI users, but we do it for the sake
# of completeness
# Structure is based on: https://stackoverflow.com/a/39671055/16358883

# Standardized function to check a parameter
function(check_parameter parameter options severity)
    set_property(CACHE TARGET PROPERTY STRINGS ${options})

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

function(check_paramater_range parameter min max)
    set_property(CACHE TARGET PROPERTY STRINGS ${options})
endfunction()

set(TARGET_OPTIONS fpga verilator)
set(THREADS_OPTIONS 1 2 3 4 5 6 7 8)
set(FLEX_OPTIONS true false)
set(ISPM_KBYTES_OPTIONS 16 32 64 128 256 512)
set(DSPM_KBYTES_OPTIONS 16 32 64 128 256 512)
set(MULTIPLIER_OPTIONS true false)
set(SUFFIX_OPTIONS min ex ti all)
set(CLK_FREQ_MHZ_OPTIONS 50 100)

check_parameter(TARGET TARGET_OPTIONS FATAL_ERROR)
check_parameter(THREADS THREADS_OPTIONS FATAL_ERROR)
check_parameter(FLEX FLEX_OPTIONS FATAL_ERROR)
check_parameter(ISPM_KBYTES ISPM_KBYTES_OPTIONS WARNING)
check_parameter(DSPM_KBYTES DSPM_KBYTES_OPTIONS WARNING)
check_parameter(MULTIPLIER MULTIPLIER_OPTIONS FATAL_ERROR)
check_parameter(SUFFIX SUFFIX_OPTIONS FATAL_ERROR)
check_parameter(CLK_FREQ_MHZ CLK_FREQ_MHZ_OPTIONS WARNING)
