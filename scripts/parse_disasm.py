#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#  parse_disasm.py
#  Parse the output of riscv32-unknown-elf-objdump and put it into a Scala
#  array constant.
#
#  Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>

import re
import sys
from typing import List

def parse_disasm(contents: str) -> List[str]:
    """
    Parse the given objdump output and return the scala array constant
    line-by-line.
    """
    output: List[str] = []

    # Strip tabs
    contents = contents.replace("\t", " ")

    output.append("(")

    for m in re.findall(r'([a-f\d]+):\s+?([a-f\d]+)\s+(.+?)$', contents, re.MULTILINE):
        output.append("  " + f"/* {m[0]} */ \"h{m[1]}\", // {m[2]}")

    output.append(")")

    return output

def main(args: List[str]) -> int:
    if len(args) < 2:
        print(f"Usage: {args[0]} <objdump_output.txt>", file=sys.stderr)
        return 1

    with open(args[1], 'r') as f:
        contents = str(f.read())

    for line in parse_disasm(contents):
        print(line)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
