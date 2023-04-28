#ifndef FLEXPRET_TIME_H
#define FLEXPRET_TIME_H

#include <stdint.h>
#include "flexpret_csrs.h"


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
/**
 * @brief Read out a 64 bit timestamp. Since it is done with two read operations
 * we must handle a potential wrapping event where we read the lower bits BEFORE the wrap
 * and the higher bits AFTER the wrap.
 * 
 * @return uint64_t 
 */
static inline uint64_t rdtime64()
{
  uint32_t lo_pre = rdtime();
  uint32_t hi = read_csr(CSR_TIMEH);
  uint32_t lo_post = rdtime();

  uint64_t res;
  if (lo_post > lo_pre) {
    // Normal situation
    res = (uint64_t) hi << 32 | lo_pre;
  } else {
    // There was a wrap. Read out higher bits again to make sure 
    uint32_t hi_post = read_csr(CSR_TIMEH);
    if (hi_post > hi) {
      // This means that we read hi BEFORE the wrap
      res = (uint64_t) hi << 32 | lo_pre;
    } else {
      // We read hi AFTER the wrap. So we subtract 1 and get the correct timestamp
      hi--;
      res = (uint64_t) hi << 32 | lo_pre;
    }
  }
  return res;
}

#endif
