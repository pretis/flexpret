#ifndef FLEXPRET_TIME_H
#define FLEXPRET_TIME_H

#include <stdint.h>
#include <flexpret/csrs.h>

/**
 * @brief Delay execution until an absolute time. Loads the timeout 
 * into the compare register of the thread. Then execute the
 * Delay Until (DU) instruction which is encoded as 0x700B.
 * 
 * The program counter (PC) is not updated until the DU instuction is finished,
 * meaning the program will go back to sleep after an interrupt has occured
 * (given that the timer has not expired).
 * 
 */
#define fp_delay_until(ns) do { \
    write_csr(CSR_COMPARE_DU_WU, (ns)); \
    __asm__ volatile(".word 0x700B;"); \
} while(0)

/**
 * @brief Delay execution for a time duration. First read the current time
 * Then do a regular `fp_delay_until`
 * 
 */
#define fp_delay_for(ns) do { \
    uint32_t now_ns = rdtime(); \
    fp_delay_until(now_ns + (ns)); \
} while(0)

/**
 * @brief Does the same as the @p fp_delay_until pseudo-instruction, but in this case
 * the program counter (PC) is incremented before the instruction completes.
 * This means that after an interrupt has completed, the program will continue.
 * 
 * The use case of this pseudo-instruction is waiting for an interrupt to occur
 * with a given timeout.
 * 
 */
#define fp_wait_until(ns) do { \
    write_csr(CSR_COMPARE_DU_WU, (ns)); \
    __asm__ volatile(".word 0x702B;"); \
} while(0)

/**
 * @brief Same as fp_delay_for, just doing wait instead of delay.
 * 
 */
#define fp_wait_for(ns) do { \
    uint32_t now_ns = rdtime(); \
    fp_wait_until(now_ns + (ns)); \
} while(0)

#define fp_nop do { \
  __asm__ volatile(".word 0x00000013;"); \
} while(0)

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
