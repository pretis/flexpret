/****************************************************************************
 * boards/risc-v/c906/smartl-c906/scripts/ld.script
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.  The
 * ASF licenses this file to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the
 * License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations
 * under the License.
 *
 ****************************************************************************/

/* 
 * Taken from https://github.com/apache/nuttx/blob/master/boards/risc-v/c906/smartl-c906/scripts/ld.script
 */

/* 
 * This either includes 
 *  `bootloader/use/bootloader.ld` or
 *  `bootloader/none/bootloader.ld` 
 * 
 * based on whether we compile with or without bootloader.
 *
 */
INCLUDE bootloader.ld
INCLUDE internal/hwconfig.ld
INCLUDE internal/swconfig.ld


ISPM_SIZE = ISPM_END - ISPM_START;
DSPM_SIZE = DSPM_END - DSPM_START;
TOTAL_STACKSIZES = STACKSIZE * NUM_THREADS;

ISPM_BOOTLOADER_END = ISPM_START + BOOTLOADER_SIZE;

/* 
 * We do not need to take bootloader's data into consideration because it is
 * copied over to DSPM in startup.c on boot.
 * 
 */
DSPM_BOOTLOADER_END = DSPM_START;

MEMORY
{
    ROM (rx)  : ORIGIN = ISPM_BOOTLOADER_END, LENGTH = ISPM_SIZE
    RAM (rwx) : ORIGIN = DSPM_BOOTLOADER_END, LENGTH = DSPM_SIZE
    STACK (rw) : ORIGIN = DSPM_END - TOTAL_STACKSIZES, LENGTH = TOTAL_STACKSIZES
}

OUTPUT_ARCH("riscv")

/**
 * To ensure _start is always located at address zero: set ENTRY(_start)
 * to let linker know we want to start at this function. Also place _start
 * function in section .zero_addr_function and place it at the very beginning
 * of .text.
 */
ENTRY(_start)
EXTERN(_vectors)
SECTIONS
{
    .text : {
        __stext = ABSOLUTE(.);
        *(.zero_addr_function)
        *(.vectors)
        *(.isr_vector)
        *(.text .text.*)
        *(.eh_frame)
        . = ALIGN(4);
        __etext = ABSOLUTE(.);
    } > ROM

    .data : ALIGN(4) {
        __sdata = ABSOLUTE(.);
        *(.data .data.*)
        *(.sdata .sdata.* .sdata2.*)
        *(.rodata .rodata.* .srodata .srodata.*)
        *(.gnu.linkonce.d.*)
        *(.gnu.linkonce.s.*)
        CONSTRUCTORS
        . = ALIGN(4);
        __edata = ABSOLUTE(.);
    } > RAM AT > ROM

    PROVIDE(__global_pointer$ = __sdata + ((__edata - __sdata) / 2));

    .bss : ALIGN(4) {
        __sbss = ABSOLUTE(.);
        *(.bss .bss.*)
        *(.sbss .sbss.*)
        *(.gnu.linkonce.b.*)
        *(.gnu.linkonce.sb.*)
        *(COMMON)
        . = ALIGN(32);
        __ebss = ABSOLUTE(.);
    } > RAM

    __end = ABSOLUTE(.);

    .heap : ALIGN(4) {
        __sheap = ABSOLUTE(.);
        __eheap = ABSOLUTE(DSPM_END - TOTAL_STACKSIZES);
    } > RAM

    .stack : ALIGN(4) {
        __estack = ABSOLUTE(.);
        __sstack =  ABSOLUTE(. + TOTAL_STACKSIZES);
    } > STACK

    PROVIDE(__stack_start$ = __sstack);
}
