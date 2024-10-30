#!/bin/bash
# Build FlexPRET emulator
#
# Arguments:
# $1: CRC32 hash
# Rest: Emulator sources

set -e

# Generates VerilatorTop.v
sbt 'run verilator h'"$1"' --no-dedup --target-dir build/emulator'

# Fetch dual port BRAM from resources
cp src/main/resources/DualPortBramEmulator.v build/emulator/DualPortBram.v


# Run Verilator command
cd build/emulator
verilator --cc VerilatorTop.v --exe --trace --trace-structs --trace-underscore --build "${@:2}"

# Copy Verilator generated binary
cp obj_dir/VVerilatorTop fp-emu
