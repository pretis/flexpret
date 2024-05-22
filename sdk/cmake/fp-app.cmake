if (NOT DEFINED TARGET)
  set(TARGET "emulator")
endif()

#[[
Generate a bash script that runs the program and place it in `bin/`. It will
appear like an executable, so the user can write `./bin/my_app`. The script can
take two widely different forms:

1. If the application targets `emulator`, the bash script will run the FlexPRET
   emulator `fp-emu` with the `+ispm` argument set to the generated `.mem` file.

2. If the application targets `fpga`, the bash script will assume the user wants
   to flash the application to the FPGA with a bootloader. It then requires a few
   additional variables, i.e., which port to use for flashing, and optionally
   a program to interface with the program after it has been uploaded. E.g.,
   `picocom`. Note that the user cannot set `UART_BAUDRATE` because it is 
   available in the installed hardware configuration.
]]
function(fp_add_script_output target)
  # These variables are used in the 
  set(IMEM_LOCATION ${CMAKE_CURRENT_BINARY_DIR})
  set(IMEM_NAME ${target}.mem)

  if (${TARGET} STREQUAL "emulator")
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/emu-app.sh.in)
  else()
    # Generate script for flashing to FPGA with bootloader
    set(INFILE $ENV{FP_SDK_PATH}/cmake/infiles/fpga-app.sh.in)
    
    set(FP_FLASH_DEVICE_DEFAULT "/dev/ttyUSB0")
    
    # Configure flash device
    # First check the environment variable; it should override any `FP_FLASH_DEVICE`
    # variables specified in the application's CMakeLists.txt
    # In this way it becomes a way to easily change the port used for all 
    # apps at once
    if (NOT DEFINED ENV{FP_SDK_FPGA_FLASH_DEVICE})
      if (NOT DEFINED FP_FLASH_DEVICE)
        message("Did not find environment variable FP_SDK_FPGA_FLASH_DEVICE nor was FP_FLASH_DEVICE set, using default ${FP_FLASH_DEVICE_DEFAULT}")
        set(FP_FLASH_DEVICE ${FP_FLASH_DEVICE_DEFAULT})
      endif()
    else()
      if (DEFINED FP_FLASH_DEVICE)
        message(WARNING
          "Overriding FPGA flash device ${FP_FLASH_DEVICE} with environment variable $ENV{FP_SDK_FPGA_FLASH_DEVICE}."
        )
      endif()
      set(FP_FLASH_DEVICE $ENV{FP_SDK_FPGA_FLASH_DEVICE})
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

# Add .map file which contains information about symbols
function(fp_add_map_output target)
  target_link_options(${target} PRIVATE
    "-Xlinker" "-Map=${target}.map"
  )
  set_property(
    TARGET ${target} APPEND PROPERTY
    ADDITIONAL_CLEAN_FILES
      "${CMAKE_CURRENT_BINARY_DIR}/${target}.map"
  )
endfunction()

# Print how much memory used at end of compilation
function(fp_print_memory_usage target)
  target_link_options(${target} PRIVATE
    "-Wl,--print-memory-usage"
  )
endfunction()

# Add all default outputs; almost all apps want this
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
