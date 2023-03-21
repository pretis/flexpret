#ifndef FLEXPRET_TIME_H
#define FLEXPRET_TIME_H

#include <stdint.h>
#include "flexpret_csrs.h"

#define MSEC(x) x*1000000U
#define USEC(x) x*1000U


/**
 * @brief Delay execution until an absolute time. Loads the timeout 
 * into the compare register of the thread. Then execute the
 * Delay Until instruction which is encoded as 0x700B.
 * 
 * @param timeout_ns 
 */
static inline void delay_until(unsigned int timeout_ns)
{
  write_csr(CSR_COMPARE, timeout_ns);
  __asm__ volatile(".word 0x700B;");
}

/**
 * @brief Delay execution for a time duration. First read the current time
 * Then do a regular `delay_until`
 * 
 * @param duration_ns 
 */
static inline void delay_for(unsigned int duration_ns)
{
  unsigned int now_ns = rdtime();
  delay_until(now_ns + duration_ns);
}

#endif
