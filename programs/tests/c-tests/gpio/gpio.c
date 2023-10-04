#include <stdint.h>
#include <flexpret.h>

static inline bool write_and_readback(const uint32_t val) {
    printf("Write gpio: 0x%x\n", val);
    gpo_write_0(val);
    const uint32_t readback = gpo_read_0();
    printf("Read  gpio: 0x%x\n", readback);
    return val == readback;
}

int main() {
    printf("--- Check initial value is zero\n");
    uint32_t x = gpo_read_0();
    printf("Read  gpio: 0x%x\n", x);    // Expect 0.
    assert(x == 0);

    printf("--- Check write and readback\n");
    assert(write_and_readback(0x01) == true);
    assert(write_and_readback(0x00) == true);
    assert(write_and_readback(0x03) == true);
    assert(write_and_readback(0x02) == true);

    printf("--- Check individual set and clear\n");
    uint32_t set = 0x01;
    printf("Set   gpio: 0x%x\n", set);

    gpo_set_0(set);                     // Set the 1st bit.
    uint32_t read = gpo_read_0();       // Expect 3.

    printf("Read  gpio: 0x%x\n", read);
    assert(read == 0x03);
    
    uint32_t clear = 0x2;
    printf("Clear gpio: 0x%x\n", clear);

    gpo_clear_0(clear);                 // Clear the 2nd bit.
    read = gpo_read_0();

    printf("Read  gpio: 0x%x\n", read);
    assert(read == 0x01);               // Expect 1.

    printf("--- Check set invalid bit\n");
    gpo_set_0(0b100);                   // Set the 3rd bit,
                                        // but couldn't because
                                        // a GPO only has 2 bits.
    assert(gpo_read_0() == 0x01);       // Expect 1.

    printf("Set invalid bit has no effect\n");

    return 0;
}
