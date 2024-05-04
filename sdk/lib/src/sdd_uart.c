/**
 * @brief 
 * 
 */

#include <flexpret/sdd_uart.h>
#include <flexpret/io.h>
#include <flexpret/time.h>
#include <flexpret/assert.h>
#include <flexpret/hwconfig.h>

#include <printf/printf.h>

#define FP_CLK_FREQ_HZ     ((int)(FP_CLK_FREQ_MHZ * 1e6))
#define NS_PER_CLK    (10) // FIXME: Depend on clk freq
#define CLKS_PER_BAUD ((int) ((FP_CLK_FREQ_HZ) / (FP_UART_BAUDRATE)))
#define NS_PER_BAUD   ((CLKS_PER_BAUD) * (NS_PER_CLK))

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

static inline bool get_pin(uint8_t port) {
    // At the time of writing this code, each port only has one bit
    return gpi_read(port);
}

static inline void set_pin(uint8_t port, bool val) {
    // At the time of writing this code, each port only has one bit
    gpo_write(port, val);
}

struct UARTContext sdd_uart_get_default_context(const uint32_t port)
{
    return (struct UARTContext) {
        .enabled = true,
        .state = STATE_STARTBIT,
        .pin = port,
        .baudrate_hz = FP_UART_BAUDRATE,
        .rbuf = {
            .rdpos = 0,
            .wrpos = 0,
            // No need to set buf
        },
    };
}

void *sdd_uart_rx(void *arg)
{
    struct UARTContext *ctx = arg;

    int nbits_rx = 0;
    uint8_t byte_rx = 0;
    uint64_t delay = 0;
    uint32_t clks_per_baud = FP_CLK_FREQ_HZ / ctx->baudrate_hz;
    uint32_t ns_per_baud = NS_PER_CLK * clks_per_baud;

    bool toggle = false;
    
    // TODO: Find a way to disable and enable
    while (ctx->enabled) {
        bool bit = get_pin(ctx->pin);
        
        switch (ctx->state)
        {
        case STATE_STARTBIT:

            // Poll on the uart line until it goes low
            // TODO: Should be an interrupt on the pin, but currently FlexPRET
            //       does not support that
            if (bit) {
                continue;
            }

            // Capture the time and delay until we are 1/2 periods into the data
            delay = rdtime() + 3 * (ns_per_baud / 2);
            ctx->state = STATE_DATABITS;

            gpo_write(0, toggle = !toggle);
            
            // Reset data bit state
            nbits_rx = 0;
            byte_rx  = 0;

            break;

        case STATE_DATABITS:

            // Shift bit into byte and check if byte is done
            byte_rx |= (bit << nbits_rx);
            if (nbits_rx++ == 7) {
                ctx->state = STATE_STOPBIT;
                //printf("go to stopbit state with byte: %x\n", byte_rx);
            }
            delay += ns_per_baud;
            gpo_write(0, toggle = !toggle);
            break;

        case STATE_STOPBIT:
            //printf("stopbit state\n");

            // Check whether stop bit is high
            if (!bit) {
                printf("Error: expected bit high on stop bit\n");
            } else {
                printf("give %x\n", byte_rx);
                buf_give(&ctx->rbuf, byte_rx);
            }
            ctx->state = STATE_STARTBIT;
            delay += 0;
            gpo_write(0, toggle = !toggle);
            break;

        default:
            fp_assert(0, "Invalid case reached\n");
            break;

        }

        fp_delay_until(delay);
    }

    return NULL;
}

uint8_t sdd_uart_rx_read(struct UARTContext *ctx)
{
    return buf_take(&ctx->rbuf);
}

uint32_t sdd_uart_rx_bytes_readable(struct UARTContext *ctx)
{
    return buf_nbytes_available(&ctx->rbuf);
}

void *sdd_uart_tx(void *arg)
{
    struct UARTContext *ctx = arg;

    int nbits_tx = 0;
    uint8_t byte_tx = 0;
    uint64_t delay = 0;

    // Default state of pin is high
    set_pin(ctx->pin, 1);

    while(ctx->enabled) {
        switch (ctx->state)
        {
        case STATE_STARTBIT:
            if (buf_nbytes_available(&ctx->rbuf) > 0) {
                ctx->state = STATE_DATABITS;
                byte_tx = buf_take(&ctx->rbuf);

                // Set pin to low (startbit)
                set_pin(ctx->pin, 0);
                delay = rdtime64() + NS_PER_BAUD;
            } else {
                delay = 0;
            }
            break;

        case STATE_DATABITS:
            bool bit = (byte_tx & (1 << nbits_tx)) != 0;
            set_pin(ctx->pin, bit);

            if (nbits_tx++ == 7) {
                ctx->state = STATE_STOPBIT;
                nbits_tx = 0;
            }

            delay += NS_PER_BAUD;

            break;
        case STATE_STOPBIT:
            // Set pin to high (stopbit)
            set_pin(ctx->pin, 1);
            ctx->state = STATE_STARTBIT;

            delay += NS_PER_BAUD;

            break;
        default:
            fp_assert(0, "Invalid case reached\n");
            break;
        }

        fp_delay_until(delay);
    }

    return NULL;
}

void sdd_uart_tx_write(struct UARTContext *ctx, const uint8_t byte)
{
    buf_give(&ctx->rbuf, byte);
}

uint32_t sdd_uart_tx_bytes_writable(struct UARTContext *ctx)
{
    return buf_nbytes_available(&ctx->rbuf);
}
