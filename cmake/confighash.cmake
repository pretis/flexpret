# Common functionality for constructing/reconstrucing configurations hashes.
# Used both by FlexPRET and sdk target.
# Assume the variables used here are already set, e.g., by ./configs/default.cmake

set(config_params 
  THREADS
  FLEX
  ISPM_KBYTES
  DSPM_KBYTES
  MULTIPLIER
  SUFFIX
  CLK_FREQ_MHZ
  UART_BAUDRATE
)

set(UNIQUE_CONFIG_STRING "")
foreach(e ${config_params})
  string(APPEND UNIQUE_CONFIG_STRING "${e} = ${${e}}\n")
endforeach()

set(UNIQUE_CONFIG_FILE
  "${CMAKE_CURRENT_BINARY_DIR}/config_readable.txt"
)

function(calculate_crc32)
  file(WRITE ${UNIQUE_CONFIG_FILE} ${UNIQUE_CONFIG_STRING})

  execute_process(
    COMMAND "python3" "-c" "import zlib; f = open(\"${UNIQUE_CONFIG_FILE}\", 'rb'); s = f.read(); print(hex(zlib.crc32(s)).replace('0x', ''))"
    OUTPUT_VARIABLE hashvar
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  set(CRC32_HASH "${hashvar}" PARENT_SCOPE)
endfunction()
