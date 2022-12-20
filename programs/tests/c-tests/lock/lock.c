#include <stdint.h>
#include <flexpret_io.h>
#include <flexpret_lock.h>

int main() {
    
    // Print the hardware thread id.
    _fp_print(read_hartid());

    // Acquire the lock.
    lock_acquire();

    // Release the lock.
    lock_release();

    _fp_print(1);
    return 0;
}

