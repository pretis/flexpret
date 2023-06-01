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
  // Read out lower and higher 32 bits of time
  uint32_t hi_pre = read_csr(CSR_TIMEH);
  uint32_t lo = rdtime();
  uint32_t hi_post = read_csr(CSR_TIMEH);
  
  uint32_t diff = hi_post - hi_pre;

  if(diff == 0) {
    return (uint64_t) ((uint64_t) hi_pre << 32) | ((uint64_t )lo);
  } else {
    // Either lo was read before wrap, or after wrap. Simple solution: Read again
    // FIXME: Proper fix to this problem is in HW. Provide atomic reading of the TIMEH and TIMEL registers
    return rdtime64();
  }
}

#endif
