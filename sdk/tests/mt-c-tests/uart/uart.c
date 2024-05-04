/**
 * @author Magnus Mæhlum (magnmaeh@stud.ntnu.no)
 * @brief This test implements a Software-defined UART, which is a more formal
 *        name for a bit-banged UART.
 * 
 */

#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <string.h>
#include <flexpret/flexpret.h>
#include <flexpret/sdd_uart.h>

static const uint8_t expected_stimuli[] = {
    #include "data.txt.h"
};

void test_expected_stimuli(struct UARTContext *ctx) {
    for (uint32_t i = 0; i < sizeof(expected_stimuli) / sizeof(expected_stimuli[0]); i++) {
        while (sdd_uart_rx_bytes_readable(ctx) <= 0);
        
        uint8_t value = sdd_uart_rx_read(ctx);
        fp_assert(value == expected_stimuli[i],
            "Did not get expected data; got %i, expected %i\n",
            value, expected_stimuli[i]);
    }
}

void test_expected_stimuli_hashed(struct UARTContext *ctx) {
    for (uint32_t i = 0; i < sizeof(expected_stimuli) / sizeof(expected_stimuli[0]); i++) {
        while (sdd_uart_rx_bytes_readable(ctx) <= 0);
        
        uint8_t value = sdd_uart_rx_read(ctx);
        fp_assert(value == (expected_stimuli[i] % 13),
            "Did not get expected data; got %i, expected %i\n",
            value, (expected_stimuli[i] % 13));
    }
}

static inline bool get_pin(uint8_t port) {
    // At the time of writing this code, each port only has one bit
    return gpi_read(port);
}

static inline void set_pin(uint8_t port, bool val) {
    // At the time of writing this code, each port only has one bit
    gpo_write(port, val);
}

int main(void) {
    printf("init\n");
    // Poll until the uart line is initialized to high
    while (get_pin(0) == 0);
    while (get_pin(1) == 0);

    printf("Got high\n");

    fp_thread_t uart_rx_tid;
    fp_thread_t uart_rx2_tid;
    struct UARTContext ctx_rx = sdd_uart_get_default_context(0);
    struct UARTContext ctx_rx2 = sdd_uart_get_default_context(1);
    ctx_rx2.baudrate_hz /= 2;

    fp_assert(
        fp_thread_create(HRTT, &uart_rx_tid, sdd_uart_rx, &ctx_rx) == 0,
        "Could not spawn thread\n"
    );

    // Should not do anything until we give it data to transmit
    fp_assert(
        fp_thread_create(HRTT, &uart_rx2_tid, sdd_uart_rx, &ctx_rx2) == 0,
        "Could not spawn thread\n"
    );
    
    //buf_give(&config_tx.rbuf, 0x55);
    //buf_give(&config_tx.rbuf, 0xAA);
    //buf_give(&config_tx.rbuf, 0x00);
    //buf_give(&config_tx.rbuf, 0xFF);
    //buf_give(&config_tx.rbuf, 0x5A);
    //buf_give(&config_tx.rbuf, 0xA5);

    // Wait until buffer is fully drained
    //while(buf_nbytes_available(&config_tx.rbuf) != 0);

    test_expected_stimuli(&ctx_rx);
    test_expected_stimuli_hashed(&ctx_rx2);

    printf("1st test success: Data received on SDD UART was correctly interpreted\n");

    ctx_rx.enabled = false;
    ctx_rx2.enabled = false;

    fp_thread_join(uart_rx_tid, NULL);
    fp_thread_join(uart_rx2_tid, NULL);


/**
 * Does not work, due to lack of synchronization between emulator and client
 * That needs to be fixed before this test can be made rigorous
 */
#if 0

    // Change the pin in run-time and run test
    config.pin = 1;
    test_expected_stimuli(&config.rbuf);

    printf("2nd test success: The pin was changed and the same test was successfully run\n");

    // Change pin back again in run-time
    config.pin = 0;
    test_expected_stimuli(&config.rbuf);

    printf("3rd test success: The pin was changed back again and test still success\n");

    config.enabled = false;
    fp_thread_join(uart_tid, NULL);

    // Now start two UARTs simultaneously, each using seperate pins
    fp_thread_t another_uart_tid = 0;
    struct UARTConfig another_config = uartconfig_get_default(1);

    config.enabled = true;
    fp_assert(
        fp_thread_create(HRTT, &uart_tid, uart_rx, &config) == 0,
        "Could not spawn thread\n"
    );
    
    fp_assert(
        fp_thread_create(HRTT, &another_uart_tid, uart_rx, &another_config) == 0,
        "Could not spawn thread\n"
    );

    test_expected_stimuli(&config.rbuf);
    test_expected_stimuli(&another_config.rbuf);

    config.enabled = false;
    another_config.enabled = false;

    fp_thread_join(uart_tid, NULL);
    fp_thread_join(another_uart_tid, NULL);

    printf("4th test success: Two UARTs were run simultaneously for two seperate pins\n");
#endif

    return 0;
}
