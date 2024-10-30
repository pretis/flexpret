#!/bin/bash
# Gather the resources needed to build FPGA with Vivado
#
# Arguments:
# $1: CRC32 hash
# $2: Current build folder
# $3: Current source folder
# $4: ISPM file, i.e., the program file

set -e

# Generate FpgaTop.v
sbt 'run fpga h'"$1"' --no-dedup --target-dir '"$2"

prjfolder=$(pwd)

# Rename FpgaTop.v to flexpret.v
cd $2
mv FpgaTop.v rtl/flexpret.v

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
RED='\033[0;31m'
NC='\033[0m'

if ! [ -f $4 ]; then
    printf "${RED}Could not find $4 needed to build FPGA.${NC}\n"
    exit 1
fi

# Copy program into build
cp $4 rtl/ispm.mem

# Copy dual port BRAM 
cp $prjfolder/src/main/resources/DualPortBramFPGA.v rtl/DualPortBram.v

# Copy project's Top.v into build
cp $3/rtl/Top.v rtl

# Create top-level constraints.xdc file
cat xdc/clock.xdc $3/xdc/Top.xdc > xdc/constraints.xdc

# Create bitstream_runnable.tcl
cat tcl/variables.tcl $3/../tcl/setup.tcl $3/../tcl/bitstream.tcl > tcl/bitstream_runnable.tcl

# Create flash_runnable.tcl
cat tcl/variables.tcl $3/../tcl/flash.tcl > tcl/flash_runnable.tcl
