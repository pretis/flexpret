# Derive other variables from the pure configuration

# Calculate log2(STACKSIZE)
execute_process(
    COMMAND "python3" "-c" "import math; print(int(math.log2(${STACKSIZE})))"
    OUTPUT_VARIABLE STACKSIZE_BITS
)
