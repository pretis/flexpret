if (NOT DEFINED TARGET)
  set(TARGET "verilator")
endif()

# When running on FPGA, we need to offset for the size of the bootloader
# in the linker scripts
if (${TARGET} STREQUAL "fpga")
  set(BOOTLOADER_SIZE_PATH "$ENV{FP_SDK_PATH}/flexpret/bootloader.cmake")
  
  if (NOT EXISTS ${BOOTLOADER_SIZE_PATH})
    message(FATAL_ERROR
      "Could not find ${BOOTLOADER_SIZE_PATH}, which is required to build software \
      for FlexPRET on FPGA using the bootloader."
  )
  endif()
  
  # Sets BOOTLOADER_SIZE
  include(${BOOTLOADER_SIZE_PATH})
else()
  set(BOOTLOADER_SIZE 0)
endif()

configure_file(
  "$ENV{FP_SDK_PATH}/cmake/infiles/bootloader.ld.in"
  "$ENV{FP_SDK_PATH}/lib/linker/internal/bootloader.ld"
)

# Generate .dump file
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

# Generate .mem and .mem.orig files
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

function(fp_setup_default target)
  set(CMAKE_EXECUTABLE_SUFFIX ".riscv" PARENT_SCOPE)

  target_link_libraries(${target} fp-sdk)
  
  fp_add_dump_output(${target})
  fp_add_mem_output(${target})
endfunction()
