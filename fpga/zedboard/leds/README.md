# LEDS

This simple example just sets four LEDs and leave four of them off. The example is meant to verify that the computer <-> FPGA setup is correct. FlexPRET is not involved in this project.

## Usage

Due to the simplicity of the project, it is not part of the CMake build system. To build the project, run the command:

`vivado -mode batch -source runVivadoLeds.tcl`

If it works, you should see every other LED light up.
