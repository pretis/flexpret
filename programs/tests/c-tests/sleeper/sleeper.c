#include <stdint.h>
#include <flexpret.h>
#include "flexpret_sleep.h"

int main() {
    
    // Print the hardware thread id.
    int x = read_hartid();
    _fp_print(x);

    _fp_print(fp_wake(0x0));
    _fp_print(fp_wake(0x0));
    _fp_print(fp_wake(0x0));
    _fp_print(fp_sleep());
    // _fp_print(fp_sleep());

    _fp_print(9);
    return 0;
}

