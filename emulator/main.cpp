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

#include "../build/hwconfig.h"

#include "pin_event.h"

void printf_init(void);
void printf_fsm(const int tid, const uint32_t reg);
void print_int_fsm(const int tid, const uint32_t reg);

uint64_t timestamp = 0;

double sc_time_stamp() {
  return timestamp;
}

static inline uint32_t get_to_host(int tid, VVerilatorTop *top) {
  switch (tid)
  {
/**
 * FP_THREADS determines how many of the to_host variables are available in the
 * VVerilatorTop class. E.g., if FP_THREADS = 2, then 
 * 
 *  top->io_to_host_0
 *  top->io_to_host_1
 * 
 * are available. The other ones would yield compilation errors if not for the
 * #if statements here.
 */
#if FP_THREADS >= 1
    case 0: return top->io_to_host_0;
#endif
#if FP_THREADS >= 2
    case 1: return top->io_to_host_1;
#endif
#if FP_THREADS >= 3
    case 2: return top->io_to_host_2;
#endif
#if FP_THREADS >= 4
    case 3: return top->io_to_host_3;
#endif
#if FP_THREADS >= 5
    case 4: return top->io_to_host_4;
#endif
#if FP_THREADS >= 6
    case 5: return top->io_to_host_5;
#endif
#if FP_THREADS >= 7
    case 6: return top->io_to_host_6;
#endif
#if FP_THREADS >= 8
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
  bool allow_imem_store = false;

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

    if (!strcmp(argv[i], "--allow-imem-store")) {
      std::cout << "IMEM store allowed" << std::endl;
      allow_imem_store = true;
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
  if (pin_client_enabled) {
    eventlist_accept_clients();
  }

  top->io_uart_rx = 1;

  int ncycles = 0;
  
  // Check for abort signals from FlexPRET and propagate the exit code
  // by returning it from the emulator
  bool should_exit = false;
  bool unknown_reason = true;
  int exit_in_n_cycles = 10;
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

#if 1
    // Does not work when emulating bootloader
    if (top->io_imem_store && !allow_imem_store) {
      printf("IMEM store when not allowed\n");
      should_exit = true;
      unknown_reason = false;
    }
#endif

    if (trace_enabled) {
      trace->dump(10*timestamp);
    }

    if (pin_client_enabled) {
      eventlist_listen();
      eventlist_set_pin(top);
    }

    top->clock = 0;
    top->eval();

    for (int i = 0; i < FP_THREADS; i++) {
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
      if (exit_in_n_cycles-- == 0) {
        if (unknown_reason) {
          printf("%s: Exit due to unknown reason\n", argv[0]);
          exitcode = EXIT_FAILURE;
        }
        break;
      }
    }

    for (int i = 0; i < FP_THREADS; i++) {
      printf_fsm(i, get_to_host(i, top));
      print_int_fsm(i, get_to_host(i, top));
    }
  }

  if (trace_enabled) {
    trace->close();
    delete trace;
  }

  delete top;
  return exitcode;
}
