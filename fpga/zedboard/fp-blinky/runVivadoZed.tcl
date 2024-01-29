# TCL script automating synthesis, implementation and programming of a Zedboard
puts "Running synthesis, implementation and programming script for Zedboard"
set outputDir ./vivado
set projectName flexpret
file mkdir $outputDir/$projectName
create_project -force -part xc7z020clg484-1 $outputDir/$projectName

puts "Adding design sources"
# Add default ISPM contents with bootloader
add_files -norecurse ispm.mem

# Add verilog sources
add_files -norecurse {DualPortBram.v Top.v flexpret.v}

# Add constraints file
add_files -fileset constrs_1 -norecurse flexpretTop.xdc
update_compile_order -fileset sources_1

puts "Creating clocking wizard IP"
# Create clocking wizard IP to control the frequency of the CPU
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0
set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} CONFIG.CLKOUT1_JITTER {151.636}] [get_ips clk_wiz_0]
update_compile_order -fileset sources_1

puts "Running synthesis"
# Synthesis
reset_run synth_1
launch_runs synth_1 -jobs 15
wait_on_runs synth_1

# Implementation and bitstream generation
puts "Running implementation"
launch_runs impl_1 -to_step write_bitstream -jobs 15
wait_on_runs impl_1


# Export Bitstream
puts "Exporting bitstream"
file copy -force $outputDir/$projectName.runs/impl_1/Top.bit zedboard.bit

puts "Programming Zedboard"
# Programming attached Zedboard
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
set_property PROGRAM.FILE {/home/magnus/ntnu/mttk/host2023/project/flexpret/fpga/zedboard/flexpret/zedboard.bit} [get_hw_devices xc7z020_1]
current_hw_device [get_hw_devices xc7z020_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z020_1] 0]

# Program Zedboard
program_hw_devices [get_hw_devices xc7z020_1]

# close project
puts "Finished"
close_project