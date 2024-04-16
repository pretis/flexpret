function(fp_add_dump_output target)
    add_custom_command(
        TARGET ${target}
        COMMAND ${CMAKE_OBJDUMP} #...
    )
    # Clean
endfunction()

function(fp_add_mem_output target)
    add_custom_command(
        TARGET ${target}
        COMMAND ${CMAKE_OBJCOPYyyy} #... TOOD:
    )

    
    # Clean
endfunction()

function(fp_add_target_outputs target)
    fp_add_dump_output(${target})
    fp_add_mem_output(${target})
endfunction()
