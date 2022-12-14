FlexPRET
================================================================================
__FlexPRET__ is a 5-stage, fine-grained multithreaded [RISC-V](http://riscv.org) processor designed specifically for _mixed-criticality (real-time embedded) systems_ and written in [Chisel](http://www.chisel-lang.org). A hardware thread scheduler decides which hardware thread to start executing each cycle, regulated by configuration and status registers. Each hardware thread is either classified as a _hard real-time thread (HRTT)_ or _soft real-time thread (SRTT)_: HRTTs are only scheduled at a constant rate for _hardware-based isolation and predictability_ (enabling independent formal verification), and SRTTs share remaining cycles (including when a HRTT doesn't need prescribed cycles) for _efficient processor utilization_. For comparison purposes, both single-threaded and round-robin multithreaded 5-stage RISC-V processors can also be generated. FlexPRET was developed at UC Berkeley as part of the [PRET](http://chess.eecs.berkeley.edu/pret/) project.

Note: the porting is not complete for the privileged RISC-V 2.0 ISA, so some tests are disabled.

For more information on the processor architecture:  
* Michael Zimmer, "[Predictable Processors for Mixed-Criticality Systems and Precision-Timed I/O](http://www2.eecs.berkeley.edu/Pubs/TechRpts/2015/EECS-2015-181.pdf)," Ph.D. Dissertation, EECS Department, University of California, Berkeley, UCB/EECS-2015-181, 2015.
* Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html). Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

# Hello Multicore

**Prerequisits**
1. 32 bit riscv-gcc installed and on the path #TODO: Link to prebuilt binaries
2. sbt #TODO: Version?
3. verilator #TODO: Version?

To get a hello-world multicore program running on a quadcore FlexPRET, proceed as follows:
1. Pull down the soc-comm dependency and publish it locally
```
cd somewhere
git clone https://github.com/t-crest/soc-comm
cd soc-comm
sbt "publishLocal"
cd back-to-flexpret
```
2. Source environment variables for convenience
```
source env.bash
```
3. Build the Quad-core FlexPRET SoC
```
make remulator
```

4. Build a simple program on 4 cores
```
cd programs/noc
make
```

This will create 4 programs core0.mem ... core3.mem. The naming is important as
Verilator expects to find those files containing the programs for each core *in
the directory in which it is invoked from*

5. Run the verilator emulator
```
fp-emu
```
Note that this must happen in the same folder as core0.mem ... core3.mem is
located.

## To understand what is going on ...
- Checkout `flexpret_wb.h` and `flexpret_noc.h` to see how the protocol FP <-> WB-master and WBmaster <-> NoC WB device
- See Top.scala to see how the multicore SoC, wishbone masters and NoC is instantiated and connected

## Current limitations
1. Only a single thread should use the Wishbone master connected to each FP core.
This means that each core should have one delegate thread doing the
communication. This fits well with the Federated execution in LF.
2. The Wishbone and NoC header-only libraries are very simple and might deadlock
   if you try to send to the wrong address. They should be revised

# Quickstart

After cloning the repository, update submodules with:

```
git submodule update --init --recursive
```

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

To run a basic Fibonnaci example in simulation, run:

```
# cd into the fib directory.
cd programs/tests/c-tests/fib/

# Compile the program.
../../../../scripts/c/riscv_compile.sh fib fib.c

# Run the simulation.
../../../../emulator/fp-emu +ispm=fib.mem

# Clean the generated files.
../../../../scripts/c/riscv_clean.sh
```

We recommend adding `scripts/c/` and `emulator/` to PATH so that `riscv_compile.sh` and `fp-emu` become directly accessible.

# Directory Structure
- `build/` Temporary folder used as part of the build
- `fpga/` Generated Verilog code and scripts for FPGA deployment
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

# Makefile Configuration

Change configuration in `config.mk` or by providing argument to make:

### FlexPRET Configuration

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

### RISC-V Compiler
We use the Newlib installation of the [RISC-V GNU Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain).

To install the 32-bit version of the GCC compiler (Newlib):
1. Clone and `cd` into the `riscv-gnu-toolchain` repository;
2. Install the necessary [prerequisites](https://github.com/riscv-collab/riscv-gnu-toolchain#prerequisites);
3. Run `./configure --prefix=/opt/riscv --with-arch=rv32i --with-abi=ilp32` (assuming your preferred installation directory is `/opt/riscv`);
4. Run `make`.

### Program Configuration
- `PROG_DIR=[path]` Directory of programs in tests/ to compile and/or run. This is the test program that is executed when running command 'make run'. The default value 'isa' means that an assembler test suite is executed.
- `PROG_CONFIG=[]` Program configuration, start with target name

### Regression Test
To run a C regression test for the current processor configurations
```
cd programs/tests/
make run-c-tests
```

# Chisel
We use Chisel version 3.4 via mill.

To learn more about Chisel, visit its [website](http://www.chisel-lang.org/) and particularly the [documentation section](https://chisel.eecs.berkeley.edu/documentation.html).

# Contributors
* Michael Zimmer (mzimmer@eecs.berkeley.edu)  
* Chris Shaver (shaver@eecs.berkeley.edu)  
* Hokeun Kim (hokeunkim@eecs.berkeley.edu)  
* David Broman (broman@eecs.berkeley.edu) 
* Edward Wang (edwardw@eecs.berkeley.edu)
* Shaokai Lin (shaokai@berkeley.edu)
