FlexPRET
================================================================================
__FlexPRET__ is a 5-stage, fine-grained multithreaded [RISC-V](http://riscv.org) processor designed specifically for _mixed-criticality (real-time embedded) systems_ and written in [Chisel](http://www.chisel-lang.org). A hardware thread scheduler decides which hardware thread to start executing each cycle, regulated by configuration and status registers. Each hardware thread is either classified as a _hard real-time thread (HRTT)_ or _soft real-time thread (SRTT)_: HRTTs are only scheduled at a constant rate for _hardware-based isolation and predictability_ (enabling independent formal verification), and SRTTs share remaining cycles (including when a HRTT doesn't need prescribed cycles) for _efficient processor utilization_. For comparison purposes, both single-threaded and round-robin multithreaded 5-stage RISC-V processors can also be generated. FlexPRET was developed at UC Berkeley as part of the [PRET](http://chess.eecs.berkeley.edu/pret/) project.

Note: the porting is not complete for the privileged RISC-V 2.0 ISA, so some tests are disabled.

For more information on the processor architecture:  
* Michael Zimmer, "[Predictable Processors for Mixed-Criticality Systems and Precision-Timed I/O](http://www2.eecs.berkeley.edu/Pubs/TechRpts/2015/EECS-2015-181.pdf)," Ph.D. Dissertation, EECS Department, University of California, Berkeley, UCB/EECS-2015-181, 2015.
* Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html). Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

# Quickstart

To build a default configuration and generate Verilog, run:

```
make fpga
```

# Unit tests
To run all unit tests:

```
mill flexpret.test
```

To run a specific unit test (e.g. SimpleCoreTest):

```
mill flexpret.test.testOnly flexpret.core.test.SimpleCoreTest
```

Unit tests are found under `src/test/scala/core/`.

# Simulation

If you would like to execute your own programs you will still need to [install the RISC-V compiler](#risc-v-compiler) (in particular, `riscv32-unknown-elf-*`), and have `verilator` installed.
Note that a modern version of Verilator is required (e.g. Verilator 4.038+).

To build the simulator, run:

```
make emulator
```

See the instructions printed after running the above, or read them in `emulator/emulator.mk` on how to use the simulator.

To run a basic Fibonnaci example, run:

```
(cd programs && ./run-sim.sh)
```

To run a simulation manually:

```
cd programs

# Compile the program
./compile.sh fib fib.c

# Generate hex file of the program for simulation
../scripts/parse_disasm.py fib.dump.txt readmemh > imem.hex.txt

# Run the simulation
../emulator/flexpret-emulator
```

# Directory Structure
- `build/` Temporary folder used as part of the build
- `fpga/` Generated Verilog code and scripts for FPGA deployment
- `programs/` C and assembly programs and test suites
  - `include/` Libraries and macros
- `scripts/` Various scripts
- `src/main/scala/` RTL source files
  - `Core/` FlexPRET processor (and baseline processors) in Chisel
  - `uart/` Verilog code for UART
- `src/test/scala/` Unit tests
- `test/` Unit testing scripts

# Makefile Configuration

**Out of date**

Change configuration in `config.mk` or by providing argument to make:

### FlexPRET Configuration

**Out of date**

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

### Target Configuration
- `TARGET=[emulator/fpga]` Select default target
- `DEBUG=[true/false]` Generate waveform dump.

### Program Configuration
- `PROG_DIR=[path]` Directory of programs in tests/ to compile and/or run. This is the test program that is executed when running command 'make run'. The default value 'isa' means that an assembler test suite is executed.
- `PROG_CONFIG=[]` Program configuration, start with target name

### Regression Test
To run a regression test for many processor configurations
```
./run-tests.py
```

# RISC-V Programs

**Out of date**

`PROG_DIR` needs to be modified to execute different programs on the emulator (e.g. `PROG_DIR=simple-mc`)

`tests/simple-mc`: A simple mixed-criticality example with 4 periodic tasks to demonstrate differences between hard real-time threads (HRTTs) and soft real-time threads (SRTTs) ([More info](tests/simple-mc/README.md))  
`tests/complex-mc`: A complex mixed-criticality example with 21 periodic tasks on 8 hardware threads to demonstrate a methodology for task mapping and thread scheduling ([More info](tests/complex-mc/README.md))  
`tests/dev/*`: Programs that are out-of-date, unsupported, or under development  

# RISC-V Compiler

**Out of date**

We use the RISC-V GCC compiler, see [riscv.org](http://riscv.org/) for more information.

RISC-V toolchain version this branch is developed against:
https://github.com/riscv/riscv-gnu-toolchain/commit/9a8a0aa98571c97291702e2e283fc1056f3ce2e2

A docker image with the compiler version installed can be created by using or modifying `docker/Dockerfile`.

# Program Compilation

To compile new programs, create a directory in `tests/` and a `test.mk` file within that directory. Within `test.mk`, define `PROG` with the names of the source C (also do `define C=1`) or assembly files, then add `$(DEFAULT_RULES)` at the botton. This will generate default compilation rules for the source files (located in `tests/tests.mk`).

To use timing instructions or other FlexPRET-specific constructs, look at files
within `tests/include`. Look at other files within `tests/` for reference.

# Chisel
We use Chisel version 3.4 via mill.

To learn more about Chisel, visit its [website](http://www.chisel-lang.org/) and particularly the [documentation section](https://chisel.eecs.berkeley.edu/documentation.html).

# Contributors
* Michael Zimmer (mzimmer@eecs.berkeley.edu)  
* Chris Shaver (shaver@eecs.berkeley.edu)  
* Hokeun Kim (hokeunkim@eecs.berkeley.edu)  
* David Broman (broman@eecs.berkeley.edu) 
* Edward Wang (edwardw@eecs.berkeley.edu)
