#include "encoding.h"

// Width <= 32
#define get_time() (read_csr(time))
#define delay_until(val) ({write_csr(uarch3, val);})

//static inline void sleep_timed(unsigned int ns) {
//   return delay_until(get_time() + ns);
//}
#define sleep_timed(val, scale) (delay_until(get_time() + (scale*val)))
#define sleep_ns(val) (sleep_timed(val, 1))
#define sleep_us(val) (sleep_timed(val, 1000))
#define sleep_ms(val) (sleep_timed(val, 1000000))

static inline void periodic_delay(unsigned int* time, unsigned int period) {
    *time += period;
    // TODO parameterize?
//    *time &= 0x7FFFFFFF;
    delay_until(*time);
}
