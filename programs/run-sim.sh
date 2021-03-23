#!/bin/bash
# Run a RISC-V C program with the Flexpret simulator.
# Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>

set -ex
set -euo pipefail

./compile.sh fib fib.c
../scripts/parse_disasm.py fib.dump.txt readmemh > imem.hex.txt

# Run the simulation
../emulator/flexpret-emulator | tee tmp-output.txt

# Check that the output is correct
if grep -q "tohost = 987" "tmp-output.txt"; then
  echo "fib(16) OK!"
  exit 0
else
  echo "fib(16) = 987 not detected!"
  exit 1
fi
