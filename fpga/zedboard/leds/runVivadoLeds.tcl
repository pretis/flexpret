# TCL script automating synthesis, implementation and programming of a Zedboard
puts "Running synthesis, implementation and programming script for Zedboard"
set outputDir ./vivado
set projectName zedboard_leds
file mkdir $outputDir/$projectName
create_project -force -part xc7z020clg484-1 $outputDir/$projectName

puts "Adding design sources"
# Add default ISPM contents with bootloader
#add_files -norecurse ispm.mem

# Add verilog sources
add_files -norecurse rtl/Top.v

# Add constraints file
add_files -fileset constrs_1 -norecurse xdc/leds.xdc
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

# TODO: Fix hard code path
set thisFile [ dict get [ info frame 0 ] file ]
set thisFolder [ file dirname thisFile ]
set_property PROGRAM.FILE { zedboard.bit } [get_hw_devices xc7z020_1]
current_hw_device [get_hw_devices xc7z020_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xc7z020_1] 0]

# Program Zedboard
program_hw_devices [get_hw_devices xc7z020_1]

# close project
puts "Finished"
close_project