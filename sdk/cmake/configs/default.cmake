# Analagous to `../cmake/configs`, this configuration file sets software
# configuration (as opposed to hardware configuration). The structure is 
# similar to that of the hardware configurations.

# Valid: Any power of 2
set(STACKSIZE 2048 CACHE STRING "The number of bytes allocated to each thread's stack" FORCE)

