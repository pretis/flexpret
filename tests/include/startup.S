.text
.global program
program:

startup:

# Initialize bss segment.
# TODO: faster
la x2, bss_start
addi x3, x0, bss_size

zero_bss:
beq x0, x3, stack
sb x0, 0(x2)
addi x2, x2, 1
addi x3, x3, -1
j zero_bss

# Initialize stack.
# TODO: not hardcoded
stack:
la sp, 0x05FFFFF8

# Store return point.
sw ra, 4(sp)

# FIXME for malardalen
addi sp, sp, -8
sw x26, 4(sp)
sw x27, 8(sp)

# Call main.
jal main

# FIXME for malardalen
lw x26, 4(sp)
lw x27, 8(sp)
addi sp, sp, 8

# Return.
lw ra, 4(sp)
jalr.r zero, ra, 0
