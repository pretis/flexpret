add_subdirectory(add)
add_subdirectory(cond)
add_subdirectory(heap)
add_subdirectory(interrupt)
add_subdirectory(lockowner)
add_subdirectory(printf)
add_subdirectory(swlock)
add_subdirectory(syscall)
add_subdirectory(threadcancel)
add_subdirectory(threadprint)

# FIXME: The UART test is not yet functional
# The reason being that it requires accurate timing which the client
# cannot provide
# Should implement another "client" which is tightly coupled with the emulator
#add_subdirectory(uart)
