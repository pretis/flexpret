#!/bin/bash

rm -f *.vcd *.txt *.hex *.riscv
ls | grep -v "\." | xargs rm
