# Setup thread scheduling, initialize

#include "asm_macros.h"
.text
.align 4
.global _start
_start:

# Only allow thread 0 to run.
csrr a0, hartid
1: bnez a0, 1b

# Initialize bss segment.
#la a0, bss_start
#la a1, bss_end
#zero_bss:
#bge a0, a1, end_zero_bss
#sb x0, 0(a0)
#addi a0, a0, 1
#j zero_bss
#end_zero_bss:

# Initialize stack.
la sp, 0x05FFFFF8

# Set scheduling frequency (execute once every T0_FREQ cycles)
li a0, T0_FREQ
SET_T0_FREQ(a0, a1, a2)

# Run C Program.
jal main

# Indicate pass/fail.
beqz v0, 1f
csrw tohost, v0
1: csrwi tohost, 15
2: b 2b

