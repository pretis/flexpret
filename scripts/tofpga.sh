#!/bin/bash
# Create memory initialization files for readmemh()
# tofpga.sh [path to program] [path to fpga project]
# Assumes 16kb memory size

function fill {
x=`wc -l < $1`
while [ $x -lt 4096  ]
do
    echo "00000000" >> $1
    x=$(($x+1))
done
}
ispm=$1.inst.mem
dspm=$1.data.mem

fill $ispm
fill $dspm
cp $ispm $2/ispm
cp $dspm $2/dspm

