puts "Programming Zedboard"

# Programming attached Zedboard
open_hw_manager
connect_hw_server -allow_non_jtag
open_hw_target
source tcl/set_program_file.tcl
current_hw_device [get_hw_devices ${partShort}_1]
refresh_hw_device -update_hw_probes false [lindex [get_hw_devices ${partShort}_1] 0]

# Program Zedboard
program_hw_devices [get_hw_devices ${partShort}_1]
