#include <stdint.h>
#include <flexpret/flexpret.h>

int main() {
    
    // Print the hardware thread id.
    printf("HW thread id: %i\n", (int) read_hartid());

    // Acquire the lock.
    fp_hwlock_acquire();

    // Release the lock.
    fp_hwlock_release();

    printf("HW lock sucessfully acquired and released\n");
    return 0;
}

