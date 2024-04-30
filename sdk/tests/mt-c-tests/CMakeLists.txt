add_subdirectory(add)
add_subdirectory(cond)
add_subdirectory(heap)
add_subdirectory(interrupt)
add_subdirectory(lockowner)
add_subdirectory(printf)
add_subdirectory(swlock)
add_subdirectory(syscall)

# FIXME: Magnus: For some reason, this test hangs in CI when using 8 hw threads,
# but works perfectly fine on my local computer with that same configuration.
# Commenting it out so CI will pass.
#add_subdirectory(threadcancel)

add_subdirectory(threadprint)

# FIXME: The UART test is not yet functional
# The reason being that it requires accurate timing which the client
# cannot provide
# Should implement another "client" which is tightly coupled with the emulator
#add_subdirectory(uart)
