#!/bin/bash
# Compile a RISC-V C program with a start script and create an objdump.
# Authors:
# - Edward Wang <edwardw@eecs.berkeley.edu>
# - Shaokai Lin <shaokai@eecs.berkeley.edu>

set -ex
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
LIB_DIR=$SCRIPT_DIR/../../programs/lib
LINKER_SCRIPT=$SCRIPT_DIR/../../programs/lib/linker-scripts/flexpret.ld
CC=riscv32-unknown-elf-gcc

$CC -I$LIB_DIR/include -T $LINKER_SCRIPT -Xlinker -Map=output.map -g -static -O0 -march=rv32i -mabi=ilp32 -nostartfiles --specs=nosys.specs -o $1 $LIB_DIR/start.S "${@:2}"
riscv64-unknown-elf-objdump -S -d $1 > $1.dump.txt
