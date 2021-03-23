# Startup code for multithreaded application, assuming hardware thread 0 is the
# master thread. Thread 0 will run set the stack pointer and run the 'main'
# function. Currently, a hardware thread cannot modify the PC of another
# hardware thread, so all other hardware threads monitor a shared data memory 
# location. When a non-zero value (desired PC) is set, the stack address is set
# from the subsequent word address, and the hardware thread jumps to this value.
# On completion, the thread will reset this value and sleep.
# Assumptions: 
#   HW: 
#       - 4 hardware threads, 16kB data
#       - thread 0 scheduled
#       - All PC on boot/reset is 'reset'
#   SW: 
#       - 'main' function
#
# Michael Zimmer (mzimmer@eecs.berkeley.edu)


.text
.align 4

# code that all threads will run on reset
reset:
# read thread ID
csrr a0, hartid
# t0 (thread ID 0) will run initialization code (init)
beqz a0, init
# all other threads will watch memory location for non-zero value
# compute address (using thread ID)
la a2, startup_state
slli a0, a0, 3
add a2, a2, a0
# check data at address and just loop if 0
wait: 
lw a0, 0(a2)
beqz a0, wait
# desired PC set, load stack address and run startup code
lw a1, 4(a2)
j startup

# executed only by thread 0
init:

# thread 0 will run main
la a1, startup_state
#lw a0, 0(a1)
la a0, main
lw a1, 4(a1)
# j startup

# startup thread, assumes a0=function, a1=stack address
startup:
# Ignored: 0 to all registers
# Ignored: 0 .bss (would require 2 more arguments)
# initialize the stack
mv sp, a1 
# run C program
jalr ra, a0, 0
# when done, behavior depends on thread
csrr a1, hartid
# for all threads except thread 0, sleep and back to reset on wake
beqz a1, done
la a2, startup_state
slli a1, a1, 3
add a2, a2, a1
sw x0, 0(a2)
#TODO: thread sleep
j reset
# for thread 0, indicate pass/fail by setting tohost to return value from
# program (if 0, set to 15; ends simulation)
done:
bnez a0, 1f
addi a0, a0, 15
1: csrw tohost, a0
2: j 2b


# Format is t0_PC, t0_stack, t1_PC, t1_stack, ...
.data
.global startup_state
startup_state:
.word main
.word startup_state+0x0FFC
.word 0
.word startup_state+0x1FFC
.word 0
.word startup_state+0x2FFC
.word 0
.word startup_state+0x3FFC
