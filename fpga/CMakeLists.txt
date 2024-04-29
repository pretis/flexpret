set(INFILE_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/cmake/infiles)

# Needed by generated Vivado .tcl files, we use it to set the number of cores
# Vivado should be using
include(ProcessorCount)
ProcessorCount(NCORES)


add_subdirectory(zedboard)
