#include <stdint.h>
#include <flexpret.h>

int main() {
    _fp_print(gpo_read_0());    // Expect 0.
    assert(gpo_read_0() == 0);
    
    gpo_write_0(2);             // Write 2.
    _fp_print(gpo_read_0());    // Expect 2.
    assert(gpo_read_0() == 2);
    
    gpo_set_0(0b1);             // Set the 1st bit.
    _fp_print(gpo_read_0());    // Expect 3.
    assert(gpo_read_0() == 3);
    
    gpo_clear_0(0b10);          // Clear the 2nd bit.
    _fp_print(gpo_read_0());    // Expect 1.
    assert(gpo_read_0() == 1);

    gpo_set_0(0b100);           // Set the 3rd bit,
                                // but couldn't because
                                // a GPO only has 2 bits.
    _fp_print(gpo_read_0());    // Expect 1.
    assert(gpo_read_0() == 1);

    return 0;
}
