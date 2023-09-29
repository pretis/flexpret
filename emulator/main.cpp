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

#include "../../programs/lib/include/flexpret_config.h"

void printf_init(void);
void printf_fsm(const int tid, const uint32_t reg);

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

  printf_init();

  while (!Verilated::gotFinish()) {
    // Hold reset high the two first clock cycles.
    if (timestamp <= 2) {
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

// TODO: Must be some better way to do this...
#if NUM_THREADS >= 1
    printf_fsm(0, top->io_to_host_0);
#endif
#if NUM_THREADS >= 2
    printf_fsm(1, top->io_to_host_1);
#endif
#if NUM_THREADS >= 3
    printf_fsm(2, top->io_to_host_2);
#endif
#if NUM_THREADS >= 4
    printf_fsm(3, top->io_to_host_3);
#endif
#if NUM_THREADS >= 5
    printf_fsm(4, top->io_to_host_4);
#endif
#if NUM_THREADS >= 6
    printf_fsm(5, top->io_to_host_5);
#endif
#if NUM_THREADS >= 7
    printf_fsm(6, top->io_to_host_6);
#endif
#if NUM_THREADS >= 8
    printf_fsm(7, top->io_to_host_7);
#endif
  }
  
  if (trace_enabled) {
    trace->close();
    delete trace;
  }

  delete top;
  return 0;
}
