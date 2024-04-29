puts "Running synthesis"

# Synthesis
reset_run synth_1
launch_runs synth_1 -jobs $nCores
wait_on_runs synth_1

# Implementation and bitstream generation
puts "Running implementation"
launch_runs impl_1 -to_step write_bitstream -jobs $nCores
wait_on_runs impl_1

# Export Bitstream
puts "Exporting bitstream"
file copy -force $outputDir/$projectName.runs/impl_1/Top.bit bitstream.bit
