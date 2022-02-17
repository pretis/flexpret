#!/bin/bash
# Compile a RISC-V C program with a start script and create an objdump.
# Authors:
# - Edward Wang <edwardw@eecs.berkeley.edu>
# - Shaokai Lin <shaokai@eecs.berkeley.edu>

set -ex
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
LIB_DIR=$SCRIPT_DIR/../../programs/lib

BIN="$1"
shift

riscv64-unknown-elf-gcc -I$LIB_DIR/include -g -static -O0 -march=rv32i -mabi=ilp32 -nostartfiles -Wl,-Ttext=0x00000000 -o $BIN $LIB_DIR/start.S $@
riscv64-unknown-elf-objdump -S -d $BIN > $BIN.dump.txt
