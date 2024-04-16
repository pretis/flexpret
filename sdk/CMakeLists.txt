include(${CMAKE_SOURCE_DIR}/cmake/riscv-toolchain.cmake)

project(fp-sdk
    DESCRIPTION "Software development kit (SDK) for FlexPRET"
    LANGUAGES C ASM
)



add_subdirectory(external)
add_subdirectory(lib)

#TODO: define __emulator__/__fpga__

# TODO: Set printf_=printf ...