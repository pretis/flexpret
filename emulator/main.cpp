/*
 * main.cpp
 * C++ main entry point for Verilator simulation.
 *
 * Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>
 */
#include "VCore.h"
#include "verilated.h"

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

int main(int argc, char* argv[]) {
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  VCore* top = new VCore;

  while (timestamp < 4000 && !Verilated::gotFinish()) {
    top->clock = 1;
    top->eval();
    timestamp++;

    top->clock = 0;
    top->eval();
    timestamp++;
  }

  delete top;
  return 0;
}
