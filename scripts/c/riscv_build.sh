#!/bin/bash
# A wrapper script that combines compilation amd parsing.
# Authors:
# - Edward Wang <edwardw@eecs.berkeley.edu>
# - Shaokai Lin <shaokai@eecs.berkeley.edu>

set -euxo pipefail

SCRIPT_DIR=$(dirname "$0")

$SCRIPT_DIR/riscv_compile.sh $1 $2
$SCRIPT_DIR/parse_disasm.py $1.dump.txt readmemh > $1.hex
