#include <stdint.h>
#include <flexpret.h>

int main() {
    
    // Print the hardware thread id.
    _fp_print(read_hartid());

    _fp_print(read_csr(0x530));

    _fp_print(1);
    return 0;
}

