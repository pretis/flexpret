#!/bin/bash
# Compile a RISC-V C program with a start script and create an objdump.
# Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>

set -ex
set -euo pipefail

output_name="$1"
shift

riscv32-unknown-elf-gcc -Iinclude -g -static -O1 -march=rv32i -mabi=ilp32 -nostartfiles -Wl,-Ttext=0x00000000 -o "$output_name" start.S "$@"
riscv32-unknown-elf-objdump -S -d "$output_name" > "$output_name.dump.txt"
