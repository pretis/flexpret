#!/bin/bash
# Check that a basic Verilog compilation of FlexPRET works.
set -ex
set -euo pipefail

./test/init.sh

# Clear old build
rm -f fpga/generated-src/Core.v

# Build
make fpga

# Check that it exists
test -f fpga/generated-src/Core.v
