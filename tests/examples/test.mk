# Compile example C programs.
# Michael Zimmer (mzimmer@eecs.berkeley.edu)

#MAX_CYCLES = 2000000
PROG ?=\
gpio \
delay_until \
sync_comm \
duty_comm \
both_comm

C_STARTUP = startup
#RISCV_S_OPTS +=
RISCV_C_OPTS += -DDEBUG_EMULATOR

$(DEFAULT_RULES)
