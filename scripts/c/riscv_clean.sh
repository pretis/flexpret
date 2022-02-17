#!/bin/bash

rm -f *.vcd *.txt
ls | grep -v "\." | xargs rm
