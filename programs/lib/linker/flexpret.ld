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
INCLUDE ../../../../build/config.ld
INCLUDE flexpret_swconfig.ld


DSPM_SIZE = DSPM_END - DSPM_START;
TOTAL_STACKSIZES = STACKSIZE * NUM_THREADS;

MEMORY
{
    ROM (rx)  : ORIGIN = ISPM_START, LENGTH = ISPM_END - ISPM_START
    RAM (rwx) : ORIGIN = DSPM_START, LENGTH = DSPM_SIZE
    STACK (rw) : ORIGIN = DSPM_END - TOTAL_STACKSIZES, LENGTH = TOTAL_STACKSIZES
}

OUTPUT_ARCH("riscv")

ENTRY(_start)
EXTERN(_vectors)
SECTIONS
{
    .text : {
        __stext = ABSOLUTE(.);
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