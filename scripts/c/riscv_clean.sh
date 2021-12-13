#!/bin/bash

rm *.vcd *txt
ls | grep -v "\." | xargs rm
