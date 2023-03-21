#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
#  simify_verilog.py
#  Parse the given Verilog file to make it suitable for simulation.
#  1) It inserts the readmemh call into the ispm to pre-load it.
#  2) It starts VCD dumping in the main module.
#
#  Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>

import re
import sys
from typing import List

def add_ispm(contents: str) -> str:
    """
    Add the given .mem filename as a loadmemh to the ispm.
    initial $readmemh("instr_mem.mem", ispm);
    """
    m = re.search(r'reg \[\d+:0\] ispm \[0:\d+\];', contents, re.MULTILINE)
    assert m is not None

    orig_str = m.group()
    new_str = f"""
initial begin
  $value$plusargs("ispm=%s", mem_file_name);
  $readmemh(mem_file_name, ispm);
end
{orig_str}
    """

    return contents.replace(orig_str, new_str)

def add_vcd(contents: str) -> str:
    """
    Add the given filename as a VCD target dump.
    Also adds some magic values to:
    - finish the simulation
    - print the next value
    """
    m = re.search(r'module Top\([\s\S]+?\);', contents, re.MULTILINE)
    assert m is not None

    orig_str = m.group()
    vcd_blob = """
initial begin
$dumpfile("trace.vcd");
$dumpvars;
end
"""

    return contents.replace(orig_str, f"{orig_str} {vcd_blob}")

def main(args: List[str]) -> int:
    if len(args) < 2:
        print(f"Usage: {args[0]} Top.v", file=sys.stderr)
        return 1

    with open(args[1], 'r') as f:
        contents = str(f.read())

    contents = add_vcd(contents)

    print(contents)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))
