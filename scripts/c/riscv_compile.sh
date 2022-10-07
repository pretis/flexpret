#!/bin/bash
# Compile a RISC-V C program with a start script and create an objdump.
# Authors:
# - Edward Wang <edwardw@eecs.berkeley.edu>
# - Shaokai Lin <shaokai@eecs.berkeley.edu>

set -ex
set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
LIB_DIR=$SCRIPT_DIR/../../programs/lib
LINKER_SCRIPT=$SCRIPT_DIR/../../programs/lib/linker/flexpret.ld
CC=riscv32-unknown-elf-gcc
OBJDUMP=riscv32-unknown-elf-objdump
OBJCOPY=riscv32-unknown-elf-objcopy
EMU=fp-emu

# Compile a C program into a riscv ELF file.
$CC -I$LIB_DIR/include -T $LINKER_SCRIPT -Xlinker -Map=output.map -g -static -O0 -march=rv32i -mabi=ilp32 -nostartfiles --specs=nosys.specs -o $1.riscv $LIB_DIR/start.S $LIB_DIR/startup.c "${@:2}"

# Generate dump file
$OBJDUMP -S -d $1.riscv > $1.dump

# Extract a binary file from the ELF file.
$OBJCOPY -O binary $1.riscv $1.binary.txt

# Generate a hex file (with a .mem extension) from the binary file.
xxd -c 4 -e $1.binary.txt | cut -c11-18 > $1.mem

# Delete the binary file.
rm $1.binary.txt

# Output message.
echo "Compilation finished. To start simulation, use \"$EMU +ispm=$1.mem\"."
