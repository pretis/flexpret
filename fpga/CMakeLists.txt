set(INFILE_LOCATION ${CMAKE_CURRENT_SOURCE_DIR}/cmake/infiles)

# Needed by generated Vivado .tcl files
include(ProcessorCount)
ProcessorCount(NCORES)


add_subdirectory(zedboard)
