function(fp_add_dump_output target)
  add_custom_command(
    TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -S -d ${target}.riscv > ${target}.dump
  )
  set_property(
    TARGET ${target} APPEND PROPERTY
    ADDITIONAL_CLEAN_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${target}.dump"
  )
endfunction()

function(fp_add_mem_output target)
  add_custom_command(
    TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary ${target}.riscv ${target}.binary.txt
    COMMAND xxd -c 4 -e ${target}.binary.txt | cut -c11-18 > ${target}.mem
    COMMAND xxd -c 4 -e ${target}.binary.txt > ${target}.mem.orig
    COMMAND rm ${target}.binary.txt
  )
  set_property(
    TARGET ${target} APPEND PROPERTY
    ADDITIONAL_CLEAN_FILES 
      "${CMAKE_CURRENT_BINARY_DIR}/${target}.mem"
      "${CMAKE_CURRENT_BINARY_DIR}/${target}.mem.orig"
  )
endfunction()

function(fp_add_extra_outputs target)
  fp_add_dump_output(${target})
  fp_add_mem_output(${target})
endfunction()
