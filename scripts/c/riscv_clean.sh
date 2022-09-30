#!/bin/bash

rm -f *.vcd *.txt *.hex *.riscv *.map *.out *.dump
ls | grep -v "\." | xargs rm
