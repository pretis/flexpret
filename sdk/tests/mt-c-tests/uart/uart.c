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

#define CLOCKFREQ     ((FP_CLK_FREQ_MHZ * 1000000)) // 100 MHz
#define NS_PER_CLK    (10)
#define UART_BAUDRATE (9600)
#define CLKS_PER_BAUD ((int) ((CLOCKFREQ) / (UART_BAUDRATE)))
#define NS_PER_BAUD   ((CLKS_PER_BAUD) * (NS_PER_CLK))

// TODO: Only one state...
enum State {
    STATE_STARTBIT,
    STATE_DATABITS,
    STATE_STOPBIT,
};

struct RingBuffer {
    uint32_t wrpos;
    uint32_t rdpos;
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

static inline bool get_bit(uint8_t bitpos) {
    // At the time of writing this code, each port only has one bit
    return gpi_read(0);
}

void* uart_rx(void *arg) {
    struct UARTConfig *config = arg;

    int nbits_rx = 0;
    uint8_t byte_rx = 0;
    uint64_t delay = 0;
    
    while (config->enabled) {
        bool bit = get_bit(config->pin);
        
        switch (config->state)
        {
        case STATE_STARTBIT:

            // Poll on the uart line until it goes low
            if (bit) {
                continue;
            }

            // Capture the time and delay until we are 1 1/2 periods into the data
            delay = rdtime64() + 3 * (NS_PER_BAUD / 2);
            config->state = STATE_DATABITS;
            
            // Reset data bit state
            nbits_rx = 0;
            byte_rx  = 0;
            break;

        case STATE_DATABITS:

            // Shift bit into byte and check if byte is done
            byte_rx |= (bit << nbits_rx);
            if (++nbits_rx == 8) {
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
            delay += NS_PER_BAUD;
            break;

        default:
            fp_assert(0, "Default case reached\n");
            break;

        }

        fp_delay_until(delay);
    }

    return NULL;
}

static const float expected_stimuli[] = {
    #include "data.txt"
};

void test_expected_stimuli(struct RingBuffer *rbuf) {
    for (int i = 0; i < sizeof(expected_stimuli) / sizeof(expected_stimuli[0]); i++) {
    while (buf_nbytes_available(rbuf) < 4) {
        fp_delay_for((int) (1e5));
    }

    float value = buf_take_float(rbuf);
    fp_assert(value == expected_stimuli[i],
        "Incorrect data. Expected: %f, got %f\n",
        expected_stimuli[i], value);
    }
}

int main(void) {
    // Poll until the uart line is initialized to high
    while (get_bit(0) == 0);
    while (get_bit(1) == 0);

    fp_thread_t uart_tid;
    struct UARTConfig config = uartconfig_get_default(0);

    fp_assert(
        fp_thread_create(HRTT, &uart_tid, uart_rx, &config) == 0,
        "Could not spawn thread\n"
    );
    
    test_expected_stimuli(&config.rbuf);

    printf("1st test success: Float values sent from client to uart were interpreted correctly\n");

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
