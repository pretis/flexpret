#!/bin/bash
# Compile a RISC-V C program with a start script and create an objdump.
# Authors:
# - Edward Wang <edwardw@eecs.berkeley.edu>
# - Shaokai Lin <shaokai@eecs.berkeley.edu>

# set -x # Useful for debugging
set -euo pipefail

help_message() {
    echo "Usage: riscv-compile.sh <thread count> <binary name> <source files...>"
    echo "Example: riscv-compile.sh 1 add add.c"
}

if [ $# -lt 3 ]; then
    echo "ERROR: At least 3 arguments required."
    help_message
    exit 1
fi

re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
   echo "ERROR: The first argument must be a number." >&2
   help_message
   exit 1
fi

SCRIPT_DIR=$(dirname "$0")
LIB_DIR=$SCRIPT_DIR/../../programs/lib
LINKER_SCRIPT=$SCRIPT_DIR/../../programs/lib/linker/flexpret.ld
CC=riscv32-unknown-elf-gcc
OBJDUMP=riscv32-unknown-elf-objdump
OBJCOPY=riscv32-unknown-elf-objcopy
EMU=fp-emu

# Compile a C program into a riscv ELF file.
# "${@:3}" = all the command line arguments starting from $3 ($3, $4, ...). 
$CC -I$LIB_DIR/include -T $LINKER_SCRIPT -Xlinker -Map=output.map -DNUM_THREADS=$1 -g -static -O0 -march=rv32i -mabi=ilp32 -nostartfiles --specs=nosys.specs -o $2.riscv $LIB_DIR/start.S $LIB_DIR/syscalls.c $LIB_DIR/tinyalloc/tinyalloc.c $LIB_DIR/startup.c $LIB_DIR/flexpret_thread.c $LIB_DIR/flexpret_lock.c "${@:3}"

# Generate dump file.
$OBJDUMP -S -d $2.riscv > $2.dump

# Extract a temporary binary file from the ELF file.
$OBJCOPY -O binary $2.riscv $2.binary.txt

# Generate a hex file (with a .mem extension) from the temporary binary file.
xxd -c 4 -e $2.binary.txt | cut -c11-18 > $2.mem
xxd -c 4 -e $2.binary.txt > $2.mem.orig

# Delete the temporary binary file.
rm $2.binary.txt

# Output message.
echo "Compilation finished. To start simulation, use \"$EMU +ispm=$2.mem\"."
