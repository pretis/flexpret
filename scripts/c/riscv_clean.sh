#!/bin/bash

rm -f *.vcd *.txt *.hex *.riscv *.map *.out
ls | grep -v "\." | xargs rm
