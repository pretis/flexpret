Under Development
================================================================================
This branch is under development for the latest versions of Chisel and RISC-V and will not always be stable with up-to-date documentation.

For previous versions, see the [riscv-2.0](https://github.com/pretis/flexpret/tree/riscv-2.0) and [RTAS14](https://github.com/pretis/flexpret/tree/RTAS14) branches 

FlexPRET
================================================================================
__FlexPRET__ is a 5-stage, fine-grained multithreaded [RISC-V*](http://riscv.org) processor designed specifically for _mixed-criticality (real-time embedded) systems_ and written in [Chisel**](https://chisel.eecs.berkeley.edu/). A hardware thread scheduler decides which hardware thread to start executing each cycle, regulated by configuration and status registers. Each hardware thread is either classified as a _hard real-time thread (HRTT)_ or _soft real-time thread (SRTT)_: HRTTs are only scheduled at a constant rate for _hardware-based isolation and predictability_ (enabling independent formal verification), and SRTTs share remaining cycles (including when a HRTT doesn't need prescribed cycles) for _efficient processor utilization_. For comparison purposes, both single-threaded and round-robin multithreaded 5-stage RISC-V processors can also be generated. FlexPRET is developed at UC Berkeley as part of the [PRET](http://chess.eecs.berkeley.edu/pret/) project.

For more information on the processor architecture:  
- Michael Zimmer, "[Predictable Processors for Mixed-Criticality Systems and Precision-Timed I/O](http://www2.eecs.berkeley.edu/Pubs/TechRpts/2015/EECS-2015-181.pdf)," Ph.D. Dissertation, EECS Department, University of California, Berkeley, UCB/EECS-2015-181, 2015.
- Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html,). Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

*[RISC-V](http://riscv.org) is an ISA developed at UC Berkeley for computer architecture research and education.
**[Chisel](https://chisel.eecs.berkeley.edu/) is an open-source hardware construction language developed at UC Berkeley that generates both Verilog and a C++ emulator.

__Contributors:__  
Michael Zimmer (mzimmer@eecs.berkeley.edu)  
Chris Shaver (shaver@eecs.berkeley.edu)  
Hokeun Kim (hokeunkim@eecs.berkeley.edu)  
David Broman (broman@eecs.berkeley.edu)  

Table of Contents:  
[Quickstart](#quickstart)  
[Directory Structure](#directory-structure)  
[Makefile Configuration](#makefile-configuration)  
[Tests](#tests)  
[RISC-V Compiler](#risc-v-compiler)  
[Program Compilation](#program-compilation)  
[Chisel](#chisel)  
[C++ Emulator](#c-emulator)  
[FPGA](#fpga)  

Quickstart
--------------------------------------------------------------------------------
We've tried to make it quick and easy to both simulate program execution on the FlexPRET processor and generate Verilog code for FPGA! 

If you would like to execute your own programs you will still need to [install the RISC-V compiler](#risc-v-compiler) and have `java` and `g++` installed.

To simulate an assembly code test suite (first run may take a few minutes to download dependencies):
```
make run
```

This will simulate the execution of the program directory `tests/isa` on FlexPRET configured with 4 hardware threads. The default configuration is set in `config.mk` and can be [changed](#flexpret-configuration). The makefile will (if needed) install [SBT](http://www.scala-sbt.org/), download Chisel, generate a C++ emulator for the FlexPRET processor, compile the C++ emulator, excute the C++ emulator on each program in the test suite, and finally display the results.

See the [tests](#tests) section for information about running other programs.

`make clean` will remove files associated with current configuration and `make cleanll` will remove files associated with all configurations.

Directory Structure
--------------------------------------------------------------------------------
- `emulator/` C++ emulator and testbench for generated processors
- `fpga/` Generated Verilog code and scripts for FPGA deployment
- `sbt/` [SBT](http://www.scala-sbt.org/) for compiling and running Chisel
- `scripts/` Various scripts
- `src/` Chisel and Verilog source files
  - `common/` Shared interfaces in Chisel
  - `Core/` FlexPRET processor (and baseline processors) in Chisel
  - `uart/` Verilog code for UART
- `tests/` C and assembly programs and test suites
  - `include/` Libraries and macros


Makefile Configuration
--------------------------------------------------------------------------------
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

### Program Configuration
- `PROG_DIR=[path]` Directory of programs in tests/ to compile and/or run. This is the test program that is executed when running command 'make run'. The default value 'isa' means that an assembler test suite is executed.
- `PROG_CONFIG=[]` Program configuration, start with target name

### Regression Test
To run a regression test for many processor configurations
```
./run-tests.py
```

Tests
--------------------------------------------------------------------------------
`PROG_DIR` needs to be modified to execute different programs on the emulator (e.g. `PROG_DIR=simple-mc`)

`tests/simple-mc`: A simple mixed-criticality example with 4 periodic tasks to demonstrate differences between hard real-time threads (HRTTs) and soft real-time threads (SRTTs) ([More info](tests/simple-mc/README.md))  
`tests/complex-mc`: A complex mixed-criticality example with 21 periodic tasks on 8 hardware threads to demonstrate a methodology for task mapping and thread scheduling ([More info](tests/complex-mc/README.md))  
`tests/dev/*`: Programs that are out-of-date, unsupported, or under development  

RISC-V Compiler
--------------------------------------------------------------------------------
We use the RISC-V GCC compiler, see [riscv.org](http://riscv.org/) for more information.

RISC-V toolchain version this branch is developed against:
https://github.com/riscv/riscv-gnu-toolchain/commit/9a8a0aa98571c97291702e2e283fc1056f3ce2e2

A docker image with the compiler version installed can be created by using or modifying `docker/Dockerfile`.

Program Compilation
--------------------------------------------------------------------------------
To compile new programs, create a directory in `tests/` and a `test.mk` file within that directory. Within `test.mk`, define `PROG` with the names of the source C (also do `define C=1`) or assembly files, then add `$(DEFAULT_RULES)` at the botton. This will generate default compilation rules for the source files (located in `tests/tests.mk`).

To use timing instructions or other FlexPRET-specific constructs, look at files
within `tests/include`. Look at other files within `tests/` for reference.

Chisel
--------------------------------------------------------------------------------
We use the Chisel version 2.2.27 that's located as a JAR file online.

To learn more about Chisel, visit their [website](https://chisel.eecs.berkeley.edu/) and particularly their [documentation section](https://chisel.eecs.berkeley.edu/documentation.html).

C++ Emulator
--------------------------------------------------------------------------------
Chisel will generate a C++ emulator for cycle-accurate behavior of the hardware design. A testbench is compiled with this emulator to simulate program execution. The testbench takes the following arguments:
- `--maxcycles=X` number of clock cycles to simulate
- `--ispm=X` location of initial instruction memory contents (each line 32-bit hex value)
- `--dspm=X` location of initial data memory contents (each line 32-bit hex value)
- `--vcd=X` (optional) location of vcd file to create
- `--vcdstart=X` (optional) cycle to start vcd creation (default is 0)

FPGA
--------------------------------------------------------------------------------
FlexPRET has been evaluated on both a Xilinx Virtex-5 and Spartan-6 FPGA.

