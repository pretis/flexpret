#include <stdint.h>
#include <flexpret.h>

/**
 * This test can be run with a client connected to the emulator; see 
 * ../../../../emulator/clients/gpio.c.
 * 
 * Set the #define to 1, recompile and connect the client to run the
 * test with the emulator.
 * 
 */
#define HAVE_EMULATOR_CLIENT (0)

static inline bool write_and_readback(const uint32_t val) {
    printf("Write gpio: 0x%x\n", val);
    gpo_write_0(val);
    const uint32_t readback = gpo_read_0();
    printf("Read  gpio: 0x%x\n", readback);
    return val == readback;
}

static void run_emulator_client_tests(void) {
    // Clear all general purpose pins
    gpo_write_0(0);
    gpo_write_1(0);
    gpo_write_2(0);
    gpo_write_3(0);

    // Wait for emulator to set general purpose pin 0
    while (gpi_read_0() == false);
    while (gpi_read_1() == false);
    while (gpi_read_0() == true);
    while (gpi_read_2() == false);
    while (gpi_read_2() == true);
    while (gpi_read_2() == false);
    while (gpi_read_3() == false);
    while (gpi_read_0() == false);

    assert(
        gpi_read_0() == true && 
        gpi_read_1() == true && 
        gpi_read_2() == true && 
        gpi_read_3() == true,
        "Pins not as expected"
    );

    while (gpi_read_2() == true);
    while (gpi_read_3() == true);
    while (gpi_read_0() == true);
    while (gpi_read_1() == true);
    
    assert(
        gpi_read_0() == false && 
        gpi_read_1() == false && 
        gpi_read_2() == false && 
        gpi_read_3() == false,
        "Pins not as expected"
    );
}

int main() {
    printf("--- Check initial value is zero\n");
    uint32_t x = gpo_read_0();
    printf("Read  gpio: 0x%x\n", x);    // Expect 0.
    assert(x == 0, "Read incorrect value");

    printf("--- Check write and readback\n");
    assert(write_and_readback(0x01) == true, "write and readback test failed");
    assert(write_and_readback(0x00) == true, "write and readback test failed");
    assert(write_and_readback(0x03) == true, "write and readback test failed");
    assert(write_and_readback(0x02) == true, "write and readback test failed");

    printf("--- Check individual set and clear\n");
    uint32_t set = 0x01;
    printf("Set   gpio: 0x%x\n", set);

    gpo_set_0(set);                     // Set the 1st bit.
    uint32_t read = gpo_read_0();       // Expect 3.

    printf("Read  gpio: 0x%x\n", read);
    assert(read == 0x03, "Read incorrect value");
    
    uint32_t clear = 0x2;
    printf("Clear gpio: 0x%x\n", clear);

    gpo_clear_0(clear);                 // Clear the 2nd bit.
    read = gpo_read_0();

    printf("Read  gpio: 0x%x\n", read);
    assert(read == 0x01, "Read incorrect value");               // Expect 1.

    printf("--- Check set invalid bit\n");
    gpo_set_0(0b100);                   // Set the 3rd bit,
                                        // but couldn't because
                                        // a GPO only has 2 bits.
    assert(gpo_read_0() == 0x01, "Read incorrect value");       // Expect 1.

    printf("Set invalid bit has no effect\n");

#if HAVE_EMULATOR_CLIENT
    run_emulator_client_tests();
    printf("Pins were toggled in a random-ish fashion test passed\n");
#endif // HAVE_EMULATOR_CLIENT

    return 0;
}
