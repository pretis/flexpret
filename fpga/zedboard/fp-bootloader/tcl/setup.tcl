file mkdir $outputDir/$projectName
create_project -force -part $part $outputDir/$projectName

puts "Adding design sources"
# Add default ISPM contents with bootloader
add_files -norecurse rtl/ispm.mem

# Add verilog sources
add_files -norecurse {rtl/DualPortBram.v rtl/Top.v rtl/flexpret.v}

# Add constraints file
add_files -fileset constrs_1 -norecurse { xdc/Top.xdc xdc/clock.xdc }
update_compile_order -fileset sources_1

puts "Creating clocking wizard IP"
# Create clocking wizard IP to control the frequency of the CPU
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wiz_0

# This is automatically generated based on configuration
source tcl/clk_wiz_config.tcl
update_compile_order -fileset sources_1
