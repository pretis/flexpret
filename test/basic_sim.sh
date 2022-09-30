#!/bin/bash
# Check that a basic simulation of FlexPRET works.
set -ex
set -euo pipefail

./test/init.sh

# Clear junk files
(cd programs && rm -f *.hex.txt Core.vcd tmp-output.txt)

# Build the emulator
make emulator

# Run the test program
(cd programs/tests/c-tests/fib/ && ../../../../scripts/c/riscv_build.sh fib fib.c && fp-emu +ispm=fib.mem && ../../../../scripts/c/riscv_clean.sh)
