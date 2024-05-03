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

#define FP_CLK_FREQ_HZ     ((int)(FP_CLK_FREQ_MHZ * 1e6))
#define NS_PER_CLK    (10) // FIXME: Depend on clk freq
#define CLKS_PER_BAUD ((int) ((FP_CLK_FREQ_HZ) / (FP_UART_BAUDRATE)))
#define NS_PER_BAUD   ((CLKS_PER_BAUD) * (NS_PER_CLK))

enum State {
    STATE_STARTBIT,
    STATE_DATABITS,
    STATE_STOPBIT,
};

struct RingBuffer {
    // TODO: Strictly speaking should have a mutex
    volatile uint32_t wrpos;
    volatile uint32_t rdpos;
    uint8_t buf[64];
};

struct UARTConfig {
    int pin;
    enum State state;
    struct RingBuffer rbuf;
    bool enabled;
};

struct UARTConfig uartconfig_get_default(const int pin) {
    return (struct UARTConfig) {
        .enabled = true,
        .state = STATE_STARTBIT,
        .pin = pin,
        .rbuf = {
            .rdpos = 0,
            .wrpos = 0,
            // No need to set buf
        },
    };
}

static void buf_give(struct RingBuffer *rbuf, uint8_t byte) {
    rbuf->buf[rbuf->wrpos++] = byte;
    if (rbuf->wrpos == sizeof(rbuf->buf)) {
        rbuf->wrpos = 0;
    }
}

static uint8_t buf_take(struct RingBuffer *rbuf) {
    const uint8_t value = rbuf->buf[rbuf->rdpos++];
    if (rbuf->rdpos == sizeof(rbuf->buf)) {
        rbuf->rdpos = 0;
    }
    return value;
}

static uint32_t buf_nbytes_available(struct RingBuffer *rbuf) {
    if (rbuf->wrpos < rbuf->rdpos) {
        // If we circled around the ringbuffer
        return rbuf->wrpos + (sizeof(rbuf->buf) - rbuf->rdpos);
    } else {
        return rbuf->wrpos - rbuf->rdpos;
    }
}

static float buf_take_float(struct RingBuffer *rbuf) {
    fp_assert(buf_nbytes_available(rbuf) >= 4,
        "Cannot take word when less than 4 bytes available\n");

    float value = 0;
    uint8_t bytes[4];

    bytes[3] = buf_take(rbuf);
    bytes[2] = buf_take(rbuf);
    bytes[1] = buf_take(rbuf);
    bytes[0] = buf_take(rbuf);

    memcpy(&value, bytes, sizeof(bytes));
    return value;
}

static inline bool get_pin(uint8_t bitpos) {
    // At the time of writing this code, each port only has one bit
    return gpi_read(0);
}

static inline bool set_pin(uint8_t bitpos, bool val) {
    // At the time of writing this code, each port only has one bit
    gpo_write(0, val);
}

static volatile uart_rx_startbit_detected = false;
void uart_rx_isr(void) {
    uart_rx_startbit_detected = true;
}

void* uart_rx(void *arg) {
    struct UARTConfig *config = arg;

    int nbits_rx = 0;
    uint8_t byte_rx = 0;
    uint64_t delay = 0;

    // TODO: Find a way to disable and enable
    while (config->enabled) {
        bool bit = get_pin(config->pin);
        
        switch (config->state)
        {
        case STATE_STARTBIT:

            // Poll on the uart line until it goes low
            // TODO: Should be an interrupt on the pin, but currently FlexPRET
            //       does not support that
            if (bit) {
                continue;
            }

            // Capture the time and delay until we are 1/2 periods into the data
            delay = rdtime64() + 3 * (NS_PER_BAUD / 2);
            config->state = STATE_DATABITS;
            
            // Reset data bit state
            nbits_rx = 0;
            byte_rx  = 0;
            break;

        case STATE_DATABITS:

            // Shift bit into byte and check if byte is done
            byte_rx |= (bit << nbits_rx);
            if (nbits_rx++ == 7) {
                config->state = STATE_STOPBIT;
            }
            delay += NS_PER_BAUD;
            break;

        case STATE_STOPBIT:

            // Check whether stop bit is high
            if (!bit) {
                printf("Error: expected bit high on stop bit\n");
            } else {
                buf_give(&config->rbuf, byte_rx);
            }
            config->state = STATE_STARTBIT;
            delay += 0;
            break;

        default:
            fp_assert(0, "Invalid case reached\n");
            break;

        }

        fp_delay_until(delay);
    }

    return NULL;
}

void *uart_tx(void *arg) {
    struct UARTConfig *config = arg;

    int nbits_tx = 0;
    uint8_t byte_tx = 0;
    uint64_t delay = 0;

    // Default state of pin is high
    set_pin(config->pin, 1);

    while(config->enabled) {
        switch (config->state)
        {
        case STATE_STARTBIT:
            if (buf_nbytes_available(&config->rbuf) > 0) {
                config->state = STATE_DATABITS;
                byte_tx = buf_take(&config->rbuf);

                // Set pin to low (startbit)
                set_pin(config->pin, 0);
                delay = rdtime64() + NS_PER_BAUD;
            } else {
                delay = 0;
            }
            break;

        case STATE_DATABITS:
            bool bit = (byte_tx & (1 << nbits_tx)) != 0;
            set_pin(config->pin, bit);

            if (nbits_tx++ == 7) {
                config->state = STATE_STOPBIT;
                nbits_tx = 0;
            }

            delay += NS_PER_BAUD;

            break;
        case STATE_STOPBIT:
            // Set pin to high (stopbit)
            set_pin(config->pin, 1);
            config->state = STATE_STARTBIT;

            delay += NS_PER_BAUD;

            break;
        default:
            fp_assert(0, "Invalid case reached\n");
            break;
        }

        fp_delay_until(delay);
    }
}

static const uint8_t expected_stimuli[] = {
    #include "data.txt.h"
};

void test_expected_stimuli(struct RingBuffer *rbuf) {
    for (int i = 0; i < sizeof(expected_stimuli) / sizeof(expected_stimuli[0]); i++) {
        while (buf_nbytes_available(rbuf) <= 0);
        
        uint8_t value = buf_take(rbuf);
        fp_assert(value == expected_stimuli[i],
            "Did not get expected data; got %i, expected %i\n",
            value, expected_stimuli[i]);
    }
}

int main(void) {
    printf("init\n");
    // Poll until the uart line is initialized to high
    while (get_pin(0) == 0);

    printf("Got high\n");

    fp_thread_t uart_rx_tid;
    fp_thread_t uart_tx_tid;
    struct UARTConfig config_rx = uartconfig_get_default(0);
    struct UARTConfig config_tx = uartconfig_get_default(0);

    fp_assert(
        fp_thread_create(HRTT, &uart_rx_tid, uart_rx, &config_rx) == 0,
        "Could not spawn thread\n"
    );

    // Should not do anything until we give it data to transmit
    fp_assert(
        fp_thread_create(HRTT, &uart_tx_tid, uart_tx, &config_tx) == 0,
        "Could not spawn thread\n"
    );
    
    buf_give(&config_tx.rbuf, 0x55);
    buf_give(&config_tx.rbuf, 0xAA);
    buf_give(&config_tx.rbuf, 0x00);
    buf_give(&config_tx.rbuf, 0xFF);
    buf_give(&config_tx.rbuf, 0x5A);
    buf_give(&config_tx.rbuf, 0xA5);

    // Wait until buffer is fully drained
    while(buf_nbytes_available(&config_tx.rbuf) != 0);

    test_expected_stimuli(&config_rx.rbuf);

    printf("1st test success: Data received on SDD UART was correctly interpreted\n");


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
