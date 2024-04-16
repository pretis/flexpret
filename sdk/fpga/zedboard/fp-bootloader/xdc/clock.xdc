## 100 MHz clock
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports {GCLK}];  # "GCLK"
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports GCLK]
