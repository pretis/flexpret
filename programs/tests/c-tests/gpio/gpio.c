#include <stdint.h>
#include <flexpret_io.h>

int main() {
    _fp_print(gpo_read(0));    // Expect 0.
    
    gpo_write(0, 2);             // Write 2.
    _fp_print(gpo_read(0));    // Expect 2.
    
    gpo_set(0, 0b1);             // Set the 1st bit.
    _fp_print(gpo_read(0));    // Expect 3.
    
    gpo_clear(0, 0b10);          // Clear the 2nd bit.
    _fp_print(gpo_read(0));    // Expect 1.

    gpo_set(0, 0b100);           // Set the 3rd bit,
                                // but couldn't because
                                // a GPO only has 2 bits.
    _fp_print(gpo_read(0));    // Expect 1.

    return 0;
}
