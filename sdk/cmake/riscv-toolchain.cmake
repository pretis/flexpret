# Copyright 2020 The IREE Authors
#
# Licensed under the Apache License v2.0 with LLVM Exceptions.
# See https://llvm.org/LICENSE.txt for license information.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

# Based on https://github.com/openxla/iree/blob/main/build_tools/cmake/riscv.toolchain.cmake

cmake_minimum_required(VERSION 3.13)

# Ensure the file does not get included twice
# If it does get included multiple times, flags will appear multiple times too
# because they are appended to already existing flags
include_guard(GLOBAL)

set(CMAKE_SYSTEM_NAME Generic)  # Explicitly set for cross-compilation
set(CMAKE_SYSTEM_PROCESSOR riscv64)
set(RISCV_HOST_TAG linux)

set(RISCV_TOOL_PATH $ENV{RISCV_TOOL_PATH_PREFIX} CACHE PATH "RISC-V tool path" FORCE)

set(RISCV_TOOLCHAIN_ROOT "${RISCV_TOOL_PATH}/bin" CACHE PATH "RISC-V compiler path")
set(RISCV_TOOLCHAIN_PREFIX "riscv-none-elf-" CACHE STRING "RISC-V toolchain prefix")
set(CMAKE_FIND_ROOT_PATH ${RISCV_TOOLCHAIN_ROOT})
list(APPEND CMAKE_PREFIX_PATH "${RISCV_TOOLCHAIN_ROOT}")

set(CMAKE_C_COMPILER "${RISCV_TOOLCHAIN_ROOT}/${RISCV_TOOLCHAIN_PREFIX}gcc")
set(CMAKE_CXX_COMPILER "${RISCV_TOOLCHAIN_ROOT}/${RISCV_TOOLCHAIN_PREFIX}g++")
set(CMAKE_STRIP "${RISCV_TOOLCHAIN_ROOT}/${RISCV_TOOLCHAIN_PREFIX}strip")
set(CMAKE_OBJDUMP "${RISCV_TOOLCHAIN_ROOT}/${RISCV_TOOLCHAIN_PREFIX}objdump")
set(CMAKE_OBJCOPY "${RISCV_TOOLCHAIN_ROOT}/${RISCV_TOOLCHAIN_PREFIX}objcopy")

set(RISCV_COMPILER_FLAGS "-g -Os -static -march=rv32i_zicsr -mabi=ilp32 -nostartfiles --specs=nosys.specs -ffunction-sections -fdata-sections -Wl,--gc-sections")
set(RISCV_COMPILER_FLAGS_CXX)
set(RISCV_COMPILER_FLAGS_DEBUG)
set(RISCV_COMPILER_FLAGS_RELEASE)
set(RISCV_LINKER_FLAGS)
set(RISCV_LINKER_FLAGS_EXE "" CACHE STRING "Linker flags for RISCV executables")

# Check if the current OS is macOS
if(${CMAKE_HOST_SYSTEM_NAME} STREQUAL "Darwin")
  # Override macOS-specific settings
  set(CMAKE_OSX_ARCHITECTURES "")
  set(CMAKE_OSX_SYSROOT "")
endif()

set(CMAKE_C_FLAGS             "${RISCV_COMPILER_FLAGS} ${CMAKE_C_FLAGS}")
set(CMAKE_CXX_FLAGS           "${RISCV_COMPILER_FLAGS} ${RISCV_COMPILER_FLAGS_CXX} ${CMAKE_CXX_FLAGS}")
set(CMAKE_ASM_FLAGS           "${RISCV_COMPILER_FLAGS} ${CMAKE_ASM_FLAGS}")
set(CMAKE_C_FLAGS_DEBUG       "${RISCV_COMPILER_FLAGS_DEBUG} ${CMAKE_C_FLAGS_DEBUG}")
set(CMAKE_CXX_FLAGS_DEBUG     "${RISCV_COMPILER_FLAGS_DEBUG} ${CMAKE_CXX_FLAGS_DEBUG}")
set(CMAKE_ASM_FLAGS_DEBUG     "${RISCV_COMPILER_FLAGS_DEBUG} ${CMAKE_ASM_FLAGS_DEBUG}")
set(CMAKE_C_FLAGS_RELEASE     "${RISCV_COMPILER_FLAGS_RELEASE} -DNDEBUG")
set(CMAKE_CXX_FLAGS_RELEASE   "${RISCV_COMPILER_FLAGS_RELEASE} -DNDEBUG")
set(CMAKE_ASM_FLAGS_RELEASE   "${RISCV_COMPILER_FLAGS_RELEASE} -DNDEBUG")
set(CMAKE_SHARED_LINKER_FLAGS "${RISCV_LINKER_FLAGS} ${CMAKE_SHARED_LINKER_FLAGS}")
set(CMAKE_MODULE_LINKER_FLAGS "${RISCV_LINKER_FLAGS} ${CMAKE_MODULE_LINKER_FLAGS}")
set(CMAKE_EXE_LINKER_FLAGS    "${RISCV_LINKER_FLAGS} ${RISCV_LINKER_FLAGS_EXE} ${CMAKE_EXE_LINKER_FLAGS}")
