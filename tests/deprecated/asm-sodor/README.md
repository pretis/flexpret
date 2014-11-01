Assembly Test Suite
================================================================================
A assembly test suite to check functionality of supported RISC-V instructions. Each test will be executed for all constant rate scheduling options for selected configuration.

### Operation
See `results/emulator/CORE_CONFIG/*.out` for test results

### Files
`test.mk`: Compilation rules 
`test_macros.h`: Macros to simplify writing tests
`riscv-*.S`: Tests
`build\`: Compiled code
`results\`: Output files, and .vcd files (if `DEBUG=true`)
