FlexPRET
================================================================================
__FlexPRET__ is a 5-stage, fine-grained multithreaded [RISC-V](http://riscv.org) processor designed specifically for _mixed-criticality (real-time embedded) systems_ and written in [Chisel](http://www.chisel-lang.org). A hardware thread scheduler decides which hardware thread to start executing each cycle, regulated by configuration and status registers. Each hardware thread is either classified as a _hard real-time thread (HRTT)_ or _soft real-time thread (SRTT)_: HRTTs are only scheduled at a constant rate for _hardware-based isolation and predictability_ (enabling independent formal verification), and SRTTs share remaining cycles (including when a HRTT doesn't need prescribed cycles) for _efficient processor utilization_. For comparison purposes, both single-threaded and round-robin multithreaded 5-stage RISC-V processors can also be generated. FlexPRET was developed at UC Berkeley as part of the [PRET](http://chess.eecs.berkeley.edu/pret/) project.

Note: the porting is not complete for the privileged RISC-V 2.0 ISA, so some tests are disabled.

For more information on the processor architecture:  
* Michael Zimmer, "[Predictable Processors for Mixed-Criticality Systems and Precision-Timed I/O](http://www2.eecs.berkeley.edu/Pubs/TechRpts/2015/EECS-2015-181.pdf)," Ph.D. Dissertation, EECS Department, University of California, Berkeley, UCB/EECS-2015-181, 2015.
* Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html). Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

# Tools and installation

## RISC-V Compiler
We use the Newlib installation of the [rv32i-4.0.0](https://github.com/stnolting/riscv-gcc-prebuilt). Download and extract it to a convenient location on the PATH. 

## Verilator
We use the `verilator` toolchain for running emulations of the core. Install it and check that the version is greater than 4.038.

```
sudo apt install verilator
verilator --version
```

## Vivado

If you intend to run FlexPRET on a Xilinx FPGA, you will need to install Vivado. Refer to Xilinx installation guides.

# Quickstart

After cloning the repository, update submodules with:

```
git submodule update --init --recursive
```

## FlexPRET unit tests
To run all unit tests for FlexPRET:

```
sbt test
```

To run a specific unit test (e.g. SimpleCoreTest):

```
sbt 'testOnly flexpret.core.test.SimpleCoreTest'
```

Unit tests are found under `src/test/scala/core/`.

## Software unit tests

To build the emulator with a default configuration and run all C tests:

```
make clean emulator
make -C programs/tests all
```

# Running software

Software can both be run on an emulator and a Field-Programmable Gate Array (FPGA). Running on an FPGA requires quite a lot of setup - we recommend running on an emulator to start. Either way, you will need to [install the RISC-V compiler](#risc-v-compiler) (in particular, `riscv32-unknown-elf-*`).

Note that software compiled for the emulator and FPGA are not compatible. Software is by default compiled for the emulator; to compile software for FPGA, see [Running on FPGA](#running-on-fpga).

## FlexPRET Configuration

- `THREADS=[1-8]` Specify number of hardware threads
- `FLEXPRET=[true/false]` Use flexible thread scheduling
- `ISPM_KBYTES=[]` Size of instruction scratchpad memory (32 bit words)
- `DSPM_KBYTES=[]` Size of instruction scratchpad memory (32 bit words)
- `SUFFIX=[min,ex,ti,all]`
    - `min`: base RV32I
    - `ex`: `min` + exceptions (necessary)
    - `ti`: `ex` + timing instructions
    - `all`: `ti` + all exception causes and stats

Not all combinations are valid.

To override the configuration, either edit the variables directly in `./Makefile` or override them through the command line, like so:

```
make clean emulator THREADS=4 ISPM_KBYTES=128
```

The built configuration is available to software through a number of generated files. The configuration files are:
* `./hwconfig.mk`
* `./swconfig.mk` (not generated)
* `./programs/lib/include/flexpret_hwconfig.h`
* `./programs/lib/include/flexpret_swconfig.h`
* `./programs/lib/linker/flexpret_swconfig.ld`
* `./programs/lib/linker/flexpret_swconfig.ld`

The use case for this is:
```C
#include <flexpret_hwconfig.h>
#include <flexpret_thread.h>

fp_thread_t tid[NUM_THREADS-1];
for (int i = 0; i < NUM_THREADS-1; i++) {
    fp_thread_create(HRTT, &tid[i], fnc, NULL);
}
```

Which will start all threads for any number of threads available on the built FlexPRET. See the tests for more example use cases.

## Running on emulator

We use `verilator` for emulation. Note that a modern version of Verilator is required (e.g. Verilator 4.038+).

To build the emulator, run `make emulator` in the root directory. This will build the default configuration. See the instructions printed after running the above, or read them in `emulator/emulator.mk` on how to use the simulator.

To run a basic Fibonnaci example in simulation, run:

```
# cd into the fib directory
cd programs/tests/c-tests/fib/

# Delete old program and compile again
make clean compile

# Run the simulation.
make run
```

Which should print out:

```
[0]: fib(16) is 987
[0]: fib(20) is 6765
[0]: ../../../..//programs/lib/syscalls/syscalls.c: 49: Finish
```

### Pin service

To set pins on the FlexPRET (e.g., to emulate external interrupts or communication protocols), refer to the [emulator client README.md](emulator/clients/README.md).

### Regression Test
To run a C regression test for the current processor configurations
```
cd programs/tests/
make
```

This will run all single-threaded test cases if the FlexPRET configuration has a single hardware thread, and both the single-threaded and multi-threaded test cases otherwise.

## Running on FPGA

Refer to the [FPGA README](./fpga/README.md) for more information on this.

# Troubleshooting

## Submodules

Ensure all git submodules are initialized and up-to-date.

```
git submodule update --init --recursive
```

# Directory Structure
- `build/` Temporary folder used as part of the build
- `programs/` C and assembly programs and test suites
  - `lib/` Libraries, linker scripts, and startup scripts
  - `tests/` C test cases
- `scripts/` Various scripts
  - `c/` Scripts for compiling C programs
  - `hdl/` Scripts for processing HDL programs
  - `fpga/` Scripts for configuring programs on an FPGA
- `src/main/scala/` RTL source files
  - `Core/` FlexPRET processor (and baseline processors) in Chisel
  - `uart/` Verilog code for UART
- `src/test/scala/` Unit tests
- `test/` Unit testing scripts

# Chisel
We use Chisel version 3.5.5.

To learn more about Chisel, visit its [website](http://www.chisel-lang.org/) and particularly the [documentation section](https://chisel.eecs.berkeley.edu/documentation.html).

# Contributors
* Michael Zimmer (mzimmer@eecs.berkeley.edu)  
* Chris Shaver (shaver@eecs.berkeley.edu)  
* Hokeun Kim (hokeunkim@eecs.berkeley.edu)  
* David Broman (broman@eecs.berkeley.edu) 
* Edward Wang (edwardw@eecs.berkeley.edu)
* Shaokai Lin (shaokai@berkeley.edu)
* Erling Jellum (erling.r.jellum@ntnu.no)
* Martin Schoeberl (masca@dtu.dk)
* Samuel Berkun (sberkun@berkeley.edu)
* Magnus Mæhlum (magnmaeh@stud.ntnu.no)
