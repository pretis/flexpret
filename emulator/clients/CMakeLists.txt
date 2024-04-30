# Very specific to current setup, if we expand on this later this will
# need some refactoring. But no need to add complexity until then

add_library(clients-common STATIC common.c)
target_include_directories(clients-common PUBLIC ".")

function(clients_add_executable target)
    add_executable(${target} ${target}.c)
    target_link_libraries(${target} PRIVATE clients-common)
endfunction()

clients_add_executable(gpio gpio.c)
clients_add_executable(interrupter interrupter.c)
clients_add_executable(uart uart.c)
clients_add_executable(stimuli stimuli.c)
clients_add_executable(stimuli-mt stimuli-mt.c)
