#include <stdint.h>
#include <flexpret/flexpret.h>
#include <flexpret/lock.h>

int main() {
    
    // Print the hardware thread id.
    printf("HW thread id: %i\n", read_hartid());

    // Acquire the lock.
    fp_hwlock_acquire();

    // Release the lock.
    fp_hwlock_release();

    printf("HW lock sucessfully acquired and released\n");
    return 0;
}

