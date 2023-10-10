#include <stdint.h>
#include <flexpret.h>
#include <flexpret_lock.h>

int main() {
    
    // Print the hardware thread id.
    printf("HW thread id: %i\n", read_hartid());

    // Acquire the lock.
    hwlock_acquire();

    // Release the lock.
    hwlock_release();

    printf("HW lock sucessfully acquired and released\n");
    return 0;
}

