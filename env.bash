export FP_ROOT=$(pwd)

# Put riscv gcc compiler on the path
# export PATH="$PATH:/opt/riscv32/bin"

# Put riscv_compile.sh and riscv_clean.sh on the path
export PATH="$PATH:$FP_ROOT/scripts/c"
# Put the generated emulator on the path
export PATH="$PATH:$FP_ROOT/emulator"