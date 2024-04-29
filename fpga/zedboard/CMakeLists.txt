# These variables are needed by Vivado .tcl files
set(BOARD_NAME zedboard)
set(PART_SHORT xc7z020)
set(PART xc7z020clg484-1)

set(FP_FPGA_BOARD_PATH ${CMAKE_CURRENT_LIST_DIR})

add_subdirectory(fp-bootloader)
add_subdirectory(fp-blinky)
