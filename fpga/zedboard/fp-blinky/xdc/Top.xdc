## This file is a general .xdc for the zedboard
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal 100 MHz
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports {INPUT_CLOCK}];  # "GCLK"
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports INPUT_CLOCK]

## LEDs
set_property -dict {PACKAGE_PIN T22 IOSTANDARD LVCMOS33} [get_ports {LEDS[0]}];  # "LD0"
set_property -dict {PACKAGE_PIN T21 IOSTANDARD LVCMOS33} [get_ports {LEDS[1]}];  # "LD1"
set_property -dict {PACKAGE_PIN U22 IOSTANDARD LVCMOS33} [get_ports {LEDS[2]}];  # "LD2"
set_property -dict {PACKAGE_PIN U21 IOSTANDARD LVCMOS33} [get_ports {LEDS[3]}];  # "LD3"
set_property -dict {PACKAGE_PIN V22 IOSTANDARD LVCMOS33} [get_ports {LEDS[4]}];  # "LD4"
set_property -dict {PACKAGE_PIN W22 IOSTANDARD LVCMOS33} [get_ports {LEDS[5]}];  # "LD5"
set_property -dict {PACKAGE_PIN U19 IOSTANDARD LVCMOS33} [get_ports {LEDS[6]}];  # "LD6"
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports {LEDS[7]}];  # "LD7"

## UART pins
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; # UART_TX is connected to IO7
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; # UART RX is connected to IO4


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
