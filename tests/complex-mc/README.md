Complex Mixed-Criticality Example
================================================================================

A complex mixed-criticality example with 21 periodic tasks on 8 hardware threads to demonstrate a methodology for task mapping and thread scheduling. Based on a sanitized avionics task set from Honeywell published in [Vestel 2007].

- A level (most critical) tasks on separate threads
- some B level (critical) tasks on a thread with a non-preemptive static scheduler
- the rest of the B level (critical) tasks on a thread with a rate-monotonic scheduler
- all C and D level (less critical) tasks on two threads that use earliest deadline first (EDF)


TODO: Table

For more information:
Michael Zimmer, David Broman, Chris Shaver, Edward A. Lee. "[FlexPRET: A Processor Platform for Mixed-Criticality Systems](http://chess.eecs.berkeley.edu/pubs/1048.html)". Proceedings of the 20th IEEE Real-Time and Embedded Technology and Application Symposium (RTAS), April, 2014.

### Operation
`CORE_CONFIG=8th-128-128-2smul-stats-exc-gt-du-ee`

See `results/emulator/CORE_CONFIG/complex-mc.out` for execution timing (and diff
with `results.out` to verify correct operation)

- All A level (most critical) tasks are isolated from all other tasks. 
- All B level tasks (critical) are HW-isolated from A, C, D level tasks and SW-isolated amongst themselves. 
- All C and D level tasks are not isolated but efficiently use spare processor cycles to meet all deadlines.

### Files
`test.mk`: Compilation rules  
`init.S`: Executed initially by each active hardware thread. Will set up memory,
thread scheduling, stack, etc. then call respective C main functions for each
thread.  
`layout-8t.ld`: Linker script for memory locations of each hardware thread  
`t*.c`: Control execution and logging of each hardware thread  
`t*_task*.c`: Code to simulate task execution  
`build\`: Compiled code  
`results\`: Output files, and .vcd files (if `DEBUG=true`)  
