Simple Mixed-Criticality Example
================================================================================

A simple mixed-criticality example with 4 periodic tasks to demonstrate differences between hard real-time threads (HRTTs) and soft real-time threads (SRTTs)

TODO: Table

For more information:
Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html)". Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

### Operation
`CORE_CONFIG=4tf-32-32-2smul-stats-exc-gt-du-ee`  
`PROG_CONFIG=emulator_normal`: Normal operation  
`PROG_CONFIG=emulator_end`: Injected error: Task D ends immediately  
`PROG_CONFIG=emulator_inf`: Injected error: Task D executes infinitely  

See `results/emulator_*/CORE_CONFIG/simple-mc.out` for execution timing (and diff with `results-*.` to verify correct execution)

In all 3 cases, task A and B will demonstrate identical behavior (isolated), whereas task C will not.

### Files
`test.mk`: Compilation rules   
`init.S`: Executed initially by each active hardware thread. Will set up memory,  
thread scheduling, stack, etc. then call respective C main functions for each
thread.
`layout-4t.ld`: Linker script for memory locations of each hardware thread  
`t*.c`: Control execution and logging of each hardware thread  
`t*_task*.c`: Code to simulate task execution  
`build\`: Compiled code  
`results\`: Output files, and .vcd files (if `DEBUG=true`)  
