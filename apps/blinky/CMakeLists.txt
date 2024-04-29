set(APPNAME blinky)

# To run on FPGA with bootloader, uncomment this line.
# To run on FPGA without bootloader, keep it commented out.
# set(TARGET "fpga")

add_executable(${APPNAME} ${APPNAME}.c)

include($ENV{FP_SDK_PATH}/cmake/fp-app.cmake)
target_link_libraries(${APPNAME} fp-sdk)

fp_add_outputs(${APPNAME})
