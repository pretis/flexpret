#include <stdint.h>
#include <flexpret/flexpret.h>

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
    printf("Write gpio: 0x%lx\n", val);
    gpo_write_0(val);
    const uint32_t readback = gpo_read_0();
    printf("Read  gpio: 0x%lx\n", readback);
    return val == readback;
}

#define AWAIT_AND_CHECK_BIT(current, expected, port, high_low, bitpos) do { \
    if (high_low == 0) { \
        expected &= ~(1 << bitpos); \
    } else { \
        expected |=  (1 << bitpos); \
    } \
    while(gpi_read_##port() == current); \
    fp_assert(gpi_read_##port() == expected, "Pin not as expected"); \
    current = expected; \
} while(0)

#if HAVE_EMULATOR_CLIENT
static void run_emulator_client_tests(void) {
    // See the client's implementation for the sequence of setting/clearing bits
    // it uses
    uint32_t current_gpi  = 0x00000000;
    uint32_t expected_gpi = 0x00000000;

    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 1, 0);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 1, 2);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 1, 7);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 1, 3);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 1, 5);

    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 0, 0);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 0, 2);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 0, 7);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 0, 3);
    AWAIT_AND_CHECK_BIT(current_gpi, expected_gpi, 0, 0, 5);
}
#endif // HAVE_EMULATOR_CLIENT

int main() {
    printf("--- Check initial value is zero\n");
    uint32_t x = gpo_read_0();
    printf("Read  gpio: 0x%lx\n", x);    // Expect 0.
    fp_assert(x == 0, "Read incorrect value");

    printf("--- Check write and readback\n");
    fp_assert(write_and_readback(0x01) == true, "write and readback test failed");
    fp_assert(write_and_readback(0x00) == true, "write and readback test failed");
    fp_assert(write_and_readback(0x03) == true, "write and readback test failed");
    fp_assert(write_and_readback(0x02) == true, "write and readback test failed");

    printf("--- Check individual set and clear\n");
    uint32_t set = 0x01;
    printf("Set   gpio: 0x%lx\n", set);

    gpo_set_0(set);                     // Set the 1st bit.
    uint32_t read = gpo_read_0();       // Expect 3.

    printf("Read  gpio: 0x%lx\n", read);
    fp_assert(read == 0x03, "Read incorrect value");
    
    uint32_t clear = 0x2;
    printf("Clear gpio: 0x%lx\n", clear);

    gpo_clear_0(clear);                 // Clear the 2nd bit.
    read = gpo_read_0();

    printf("Read  gpio: 0x%lx\n", read);
    fp_assert(read == 0x01, "Read incorrect value");               // Expect 1.

    printf("--- Check set invalid bit\n");
    gpo_set_0(0b100);                   // Set the 3rd bit,
                                        // but couldn't because
                                        // a GPO only has 2 bits.
    fp_assert(gpo_read_0() == 0x01, "Read incorrect value");       // Expect 1.

    printf("Set invalid bit has no effect\n");

#if HAVE_EMULATOR_CLIENT
    run_emulator_client_tests();
    printf("Pins were toggled in a random-ish fashion test passed\n");
#endif // HAVE_EMULATOR_CLIENT

    return 0;
}
