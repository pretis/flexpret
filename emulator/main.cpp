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

#include "../../programs/lib/include/flexpret_hwconfig.h"

#include "pin_event.h"

void printf_init(void);
void printf_fsm(const int tid, const uint32_t reg);

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

static inline uint32_t get_to_host(int tid, VVerilatorTop *top) {
  switch (tid)
  {
/**
 * NUM_THREADS determines how many of the to_host variables are available in the
 * VVerilatorTop class. E.g., if NUM_THREADS = 2, then 
 * 
 *  top->io_to_host_0
 *  top->io_to_host_1
 * 
 * are available. The other ones would yield compilation errors if not for the
 * #if statements here.
 */
#if NUM_THREADS >= 1
    case 0: return top->io_to_host_0;
#endif
#if NUM_THREADS >= 2
    case 1: return top->io_to_host_1;
#endif
#if NUM_THREADS >= 3
    case 2: return top->io_to_host_2;
#endif
#if NUM_THREADS >= 4
    case 3: return top->io_to_host_3;
#endif
#if NUM_THREADS >= 5
    case 4: return top->io_to_host_4;
#endif
#if NUM_THREADS >= 6
    case 5: return top->io_to_host_5;
#endif
#if NUM_THREADS >= 7
    case 6: return top->io_to_host_6;
#endif
#if NUM_THREADS >= 8
    case 7: return top->io_to_host_7;
#endif
  default:
    assert(0);
    return -1;
  }
}

int main(int argc, char* argv[]) {
  int exitcode = EXIT_SUCCESS;

  bool trace_enabled = false;
  bool pin_client_enabled = false;

  for (int i = 1; i< argc; i++) {
    if (!strcmp(argv[i], "--trace")) {
      std::cout << "Tracing enabled" << std::endl;
      trace_enabled = true;
    }

    // Enable this to allow clients to connect; see the ./clients folder
    if (!strcmp(argv[i], "--client")) {
      std::cout << "Pin client enabled" << std::endl;
      pin_client_enabled = true;
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
  std::list<pin_event_t> in_exts_0_events = {};
  if (pin_client_enabled) {
    eventlist_accept_clients();
  }

  int ncycles = 0;
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

    if (pin_client_enabled) {
      eventlist_listen(in_exts_0_events);
      eventlist_set_pin(in_exts_0_events, top);
    }

    top->clock = 0;
    top->eval();

    // Check for abort signals from FlexPRET and propagate the exit code
    // by returning it from the emulator
    bool should_exit = false;
    bool unknown_reason = true;
    for (int i = 0; i < NUM_THREADS; i++) {
      const uint32_t to_host = get_to_host(i, top);
      
      if (to_host == 0xdeaddead) {
        exitcode = EXIT_SUCCESS;
        unknown_reason = false;
        should_exit = true;
      } else if (to_host == 0xdeadbeef) {
        exitcode = EXIT_FAILURE;
        unknown_reason = false;
        should_exit = true;
      }
    }

    if (should_exit) {
      if (unknown_reason) {
        printf("%s: Exit due to unknown reason\n", argv[0]);
        exitcode = EXIT_FAILURE;
      }
      break;
    }

    for (int i = 0; i < NUM_THREADS; i++) {
      printf_fsm(i, get_to_host(i, top));
    }
  }

  if (trace_enabled) {
    trace->close();
    delete trace;
  }

  delete top;
  return exitcode;
}
