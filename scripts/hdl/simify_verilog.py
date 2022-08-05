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
    Add the given hex filename as a loadmemh to the ispm.
    initial $readmemh("instr_mem.hex.txt", ispm);
    """
    m = re.search(r'reg \[\d+:0\] ispm \[0:\d+\];', contents, re.MULTILINE)
    assert m is not None

    orig_str = m.group()
    new_str = f"""
initial begin
  $value$plusargs("ispm=%s", hex_file_name);
  $readmemh(hex_file_name, ispm);
end
{orig_str} 
    """

    return contents.replace(orig_str, new_str)

def add_cycle(contents: str) -> str:
    """
    Print cycle-by-cycle statements
    """
    m = re.search(r'module Datapath\([\s\S]+?\);', contents, re.MULTILINE)
    assert m is not None

    orig_str = m.group()
    new_str = f"""
initial begin
  $value$plusargs("cycle=%s", cycle);
  // $display("+cycle = %s", cycle);
end

always @(posedge clock) begin

  if (cycle == "true") begin
    // the default tid is 0
    $display("[0] pc = [0x%h] inst = [0x%h] DASM(0x%h)", exe_reg_pc, dec_reg_inst, dec_reg_inst);
  end

end
    """

    return contents.replace(orig_str, f"{orig_str} {new_str}")

def add_vcd(contents: str) -> str:
    """
    Add the given filename as a VCD target dump.
    Also adds some magic values to:
    - finish the simulation
    - print the next value
    """
    m = re.search(r'module Core\([\s\S]+?\);', contents, re.MULTILINE)
    assert m is not None

    orig_str = m.group()
    vcd_blob = """
initial begin
$dumpfile({hex_file_name, ".vcd"});
$dumpvars;
end

// Previous value of tohost (NOT the previous CYCLE's value)
reg [31:0] prev_tohost = 32'h0;

// Previous CYCLE's value; used for change detection.
// P.S. Verilog sucks. Easier to do RegNext() in Chisel.
reg [31:0] lastCycle_tohost = 32'h0;

always @(posedge clock) begin
  lastCycle_tohost <= io_host_to_host;

  // If the value changed this cycle, update prev_tohost
  if (io_host_to_host != lastCycle_tohost) begin
    prev_tohost <= io_host_to_host;
    // Since the value changed, check the previous value and print
    // if need be.
    if (prev_tohost == 32'hbaaabaaa) begin
      $display("tohost = %0d", io_host_to_host);
      //$display("tohost_p = 0x%H", prev_tohost);
    end
  end else begin
    prev_tohost <= prev_tohost;
  end

  if (io_host_to_host == 32'hdeaddead) begin
    $finish;
  end
end
"""

    return contents.replace(orig_str, f"{orig_str} {vcd_blob}")

'''
args = ['scripts/hdl/simify_verilog.py', 'build/Core.raw.v']
'''
def main(args: List[str]) -> int:
    if len(args) < 2:
        print(f"Usage: {args[0]} Core.v", file=sys.stderr)
        return 1

    with open(args[1], 'r') as f:
        contents = str(f.read())

    contents = "string hex_file_name;\n" + contents
    contents = "string cycle;\n" + contents
    contents = add_cycle(contents)
    contents = add_ispm(contents)
    contents = add_vcd(contents)

    print(contents)

    return 0

if __name__ == '__main__':
    sys.exit(main(sys.argv))