/*
 * main.cpp
 * C++ main entry point for Verilator simulation.
 *
 * Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>
 * Copyright 2023 Erling Rennemo Jellum <erling.r.jellum@ntnu.no>
 */
#include "VVerilatorTop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include <iostream>

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

int main(int argc, char* argv[]) {
  bool trace_enabled = false;
  for (int i = 1; i< argc; i++) {
    if (!strcmp(argv[i], "--trace")) {
      std::cout << "Tracing enabled" << std::endl;
      trace_enabled = true;
    }
  }

  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);

  VVerilatorTop * top = new VVerilatorTop;
  VerilatedVcdC *trace;
  if (trace_enabled) {
    trace = new VerilatedVcdC;
    top->trace(trace, 99);
    trace->open("trace.vcd");
  }

  // FIXME: Set this via command-line arguments.
  while (!Verilated::gotFinish()) {
    // Hold reset high the very first clock cycle.
    if (timestamp == 0) {
      top->reset = 1;
    } else {
      top->reset = 0;
    }

    top->clock = 1;
    top->eval();
    timestamp++;

    if (trace_enabled) {
      trace->dump(10*timestamp);
    }

    top->clock = 0;
    top->eval();
    timestamp++;

    if (trace_enabled) {
      trace->dump(10*timestamp);
      trace->flush();
    }

    if(top->io_stop == 1) {
      break;
    }
  }

  if (trace_enabled) {
    trace->close();
    delete trace;
  }

  delete top;
  return 0;
}
