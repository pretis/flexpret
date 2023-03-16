/*
 * main.cpp
 * C++ main entry point for Verilator simulation.
 *
 * Copyright 2021 Edward Wang <edwardw@eecs.berkeley.edu>
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
  Verilated::commandArgs(argc, argv);
  bool trace_enabled = false;
  if (argc == 2) {
    if (!strcmp(argv[1], "--trace")) {
      std::cout << "Tracing enabled" << std::endl;
      trace_enabled = true;
    }
  }

  Verilated::traceEverOn(true);


  VVerilatorTop * top = new VVerilatorTop;
  VerilatedVcdC *trace;
  if (trace_enabled) {
    trace = new VerilatedVcdC;
    top->trace(trace, 99);
    trace->open("trace.vcd");
  }
  


  // FIXME: Set this via command-line arguments.
  while (timestamp < 3000000 && !Verilated::gotFinish()) {
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
