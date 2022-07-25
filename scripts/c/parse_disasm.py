#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#  parse_disasm.py
#  Parse the output of riscv32-unknown-elf-objdump and put it into a Scala
#  array constant, or readmemh hex file.
#
#  Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>

from dataclasses import dataclass
import re
import sys
from typing import List

@dataclass(frozen=True)
class Instruction:
    offset: str # e.g. c
    instr: str # e.g. 00008067
    comment: str # e.g. jr ra

def parse_disasm(contents: str) -> List[Instruction]:
    """
    Parse the given objdump output.
    """
    output: List[Instruction] = []

    # Strip tabs
    contents = contents.replace("\t", " ")

    for m in re.findall(r'([a-f\d]+):\s+?([a-f\d]+)\s+(.+?)$', contents, re.MULTILINE):
        output.append(Instruction(offset=m[0], instr=m[1], comment=m[2]))

    return output

def to_scala(prog: List[Instruction]) -> List[str]:
    """
    Format the given program as a Scala array constant line-by-line.
    """
    output: List[str] = []

    output.append("(")

    for instr in prog:
        output.append("  " + f"/* {instr.offset} */ \"h{instr.instr}\", // {instr.comment}")

    output.append(")")

    return output

def to_readmemh(prog: List[Instruction]) -> List[str]:
    """
    Format the given program as a readmemh file.
    """
    output: List[str] = []
    for instr in prog:
        output.append(instr.instr)
    return output

def main(args: List[str]) -> int:
    if len(args) < 3:
        print(f"Usage: {args[0]} <objdump_output.txt> <format: scala or readmemh>", file=sys.stderr)
        return 1

    objdump_out: str = str(args[1])
    type_output: str = str(args[2])
    if type_output not in ('scala', 'readmemh'):
        print(f"Invalid output type {type_output}", file=sys.stderr)
        return 1

    with open(objdump_out, 'r') as f:
        contents = str(f.read())

    prog = parse_disasm(contents)

    output: List[str] = []
    if type_output == 'scala':
        output = to_scala(prog)
    else:
        output = to_readmemh(prog)

    for line in output:
        print(line)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
