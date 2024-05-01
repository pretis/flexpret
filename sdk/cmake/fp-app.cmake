if (NOT DEFINED TARGET)
  set(TARGET "emulator")
endif()

function(fp_add_script_output target)
  set(IMEM_LOCATION ${CMAKE_CURRENT_BINARY_DIR})
  set(IMEM_NAME ${target}.mem)

  if (${TARGET} STREQUAL "emulator")
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/emu-app.sh.in)
  else()
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/fpga-app.sh.in)
    
    # Configure flash device
    set(FP_FLASH_DEVICE_DEFAULT "/dev/ttyUSB0")
    
    if (NOT DEFINED ENV{FP_SDK_FPGA_FLASH_DEVICE})
      if (NOT DEFINED FP_FLASH_DEVICE)
        message("Did not find environment variable FP_SDK_FPGA_FLASH_DEVICE nor was FP_FLASH_DEVICE set, using default ${FP_FLASH_DEVICE_DEFAULT}")
        set(FP_FLASH_DEVICE ${FP_FLASH_DEVICE_DEFAULT})
      endif()
    else()
      set(FP_FLASH_DEVICE $ENV{FP_SDK_FPGA_FLASH_DEVICE})
    endif()
    
    # Configure interface program
    if (NOT DEFINED ENV{FP_SDK_FPGA_INTERFACE_PROGRAM})
      message("Did not find environment variable FP_SDK_FPGA_INTERFACE_PROGRAM, using none")
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

function(fp_add_map_output target)
  target_link_options(${target} PRIVATE
    "-Xlinker" "-Map=${target}.map"
  )
endfunction()

function(fp_print_memory_usage target)
  target_link_options(${target} PRIVATE
    "-Wl,--print-memory-usage"
  )
endfunction()

function(fp_add_outputs executable)
  fp_add_script_output(${executable})
  fp_add_dump_output(${executable})
  fp_add_mem_output(${executable})
  fp_add_map_output(${executable})
  fp_print_memory_usage(${executable})

  if (${TARGET} STREQUAL "fpga")
    set(LINKER_INCLUDE "$ENV{FP_SDK_PATH}/lib/linker/bootloader/use")
  else()
    set(LINKER_INCLUDE "$ENV{FP_SDK_PATH}/lib/linker/bootloader/none")
  endif()

  target_link_options(${executable} PRIVATE "-Wl,-L" ${LINKER_INCLUDE})
endfunction()
