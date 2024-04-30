## This file is a general .xdc for the zedboard
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

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
set_property -dict {PACKAGE_PIN Y11 IOSTANDARD LVCMOS33} [get_ports {UART_TX}];  # "JA1"
set_property -dict {PACKAGE_PIN AA11 IOSTANDARD LVCMOS33} [get_ports {UART_RX}];  # "JA2"
set_property -dict {PACKAGE_PIN Y10 IOSTANDARD LVCMOS33}  [get_ports {JA3}];  # "JA3"
set_property -dict {PACKAGE_PIN AA9 IOSTANDARD LVCMOS33}  [get_ports {JA4}];  # "JA4"
set_property -dict {PACKAGE_PIN AB11 IOSTANDARD LVCMOS33} [get_ports {JA7}];  # "JA7"
set_property -dict {PACKAGE_PIN AB10 IOSTANDARD LVCMOS33} [get_ports {JA8}];  # "JA8"
set_property -dict {PACKAGE_PIN AB9 IOSTANDARD LVCMOS33}  [get_ports {JA9}];  # "JA9"
set_property -dict {PACKAGE_PIN AA8 IOSTANDARD LVCMOS33}  [get_ports {JA10}];  # "JA10"


## Interrupt pins
set_property PACKAGE_PIN W12 [get_ports {INTS[0]}];  # "JB1"
set_property PACKAGE_PIN W11 [get_ports {INTS[1]}];  # "JB2"

## Sync pin
set_property PACKAGE_PIN V10 [get_ports {SYNC}];  # "JB3"

## Buttons
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {RESET}];  # "BTNC"

## Switches
set_property -dict {PACKAGE_PIN F22 IOSTANDARD LVCMOS33} [get_ports {SWS[0]}];  # "SW0"
set_property -dict {PACKAGE_PIN G22 IOSTANDARD LVCMOS33} [get_ports {SWS[1]}];  # "SW1"

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
