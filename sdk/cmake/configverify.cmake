# Import function common to checking hardware and software config
include("$ENV{FP_PATH}/cmake/lib/check.cmake")

set(STACKSIZE_OPTIONS 512 1024 2048 4096)

check_parameter(STACKSIZE STACKSIZE_OPTIONS FATAL_ERROR)
