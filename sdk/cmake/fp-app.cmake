if (NOT DEFINED TARGET)
  set(TARGET "emulator")
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

function(fp_add_script_output target)
  set(IMEM_LOCATION ${CMAKE_CURRENT_BINARY_DIR})
  set(IMEM_NAME ${target}.mem)

  if (${TARGET} STREQUAL "emulator")
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/emu-app.sh.in)
  else()
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/fpga-app.sh.in)
    if (NOT DEFINED FP_FLASH_DEVICE)
      set(FP_FLASH_DEVICE "/dev/ttyUSB0")
    endif()

    if (NOT DEFINED ENV{FP_SDK_FPGA_INTERFACE_PROGRAM})
      message("Did not find environment variable FP_SDK_FPGA_INTERFACE_PROGRAM, using ")
      set(FP_INTERFACE_PROGRAM "picocom")
    else()
      message("Found environment variable FP_SDK_FPGA_INTERFACE_PROGRAM (=$ENV{FP_SDK_FPGA_INTERFACE_PROGRAM}).")
      set(FP_INTERFACE_PROGRAM $ENV{FP_SDK_FPGA_INTERFACE_PROGRAM})
    endif()
    
    # hwconfig.cmake contains UART_BAUDRATE variable
    include($ENV{FP_SDK_PATH}/flexpret/hwconfig.cmake)
  endif()

  configure_file(
    ${INFILE}
    ${CMAKE_SOURCE_DIR}/bin/${target}
    FILE_PERMISSIONS 
      OWNER_EXECUTE # Need execute, the others are normal permissions
      OWNER_READ 
      OWNER_WRITE 
      GROUP_READ 
      WORLD_READ
    @ONLY
  )
  set_property(
    TARGET ${target} APPEND PROPERTY
    ADDITIONAL_CLEAN_FILES
      ${CMAKE_SOURCE_DIR}/bin
  )
endfunction()

# Generate .dump file
function(fp_add_dump_output target)
  add_custom_command(
    TARGET ${target} POST_BUILD
    COMMAND ${CMAKE_OBJDUMP} -S -d ${target} > ${target}.dump
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
    COMMAND ${CMAKE_OBJCOPY} -O binary ${target} ${target}.binary.txt
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

function(fp_add_outputs target)
  fp_add_dump_output(${target})
  fp_add_mem_output(${target})
  fp_add_script_output(${target})
endfunction()
