/**************************************************
 * FlexPRET timing instruction functions          *
 * By David Broman, 2013                          *
 *************************************************/


#ifndef __PRET_H
#define __PRET_H

/** 
 * Function get_time_low() returns the lower 32 bits 
 * of the current time (in nano seconds). Note that
 * this function can optionally be followed by a
 * function call to get_time_high() to retrieve the
 * higher 32 bits of the complete 64-bit value. 
 * These two calles are atomic; get_time_low() stores
 * internally the higher value in hardware.
 */
static inline unsigned int get_time_low()
{
  int retval;
  __asm__ __volatile__(".word 0x1000005B;"
                       "addi %[retv],x2,0;"     
                       : [retv]"=r"(retval)
                       :
                       : "x2");
  return retval;
}



/**
 * Function get_time_high() returns the upper 32 bits
 * of current time (in nano seconds). Note that this
 * function must allows follow a call to get_time_low().
 */
static inline unsigned int get_time_high()
{
  int retval;
  __asm__ __volatile__(".word 0x180000DB;"
                       "addi %[retv],x3,0;"     
                       : [retv]"=r"(retval)
                       :
                       : "x3");
  return retval;
}


#define get_time(h,l) \
  {l = get_time_low(); h = get_time_high();}

/** 
 * Macro for adding time to a 64-bit time value that is
 * split into two 32-bit values. 
 * See macros add_ms(), add_us(), and add_ns() below.
 */ 
#define add_timed_val(h,l,val,scale) ({\
     l += val*scale;\
     if((unsigned int) l < (unsigned int) val*scale) h++;})

                                            
/* 
 * Macro add_ms(h,l,val) adds 'val' number of milli seconds
 * to a time value, stored in 'h' and 'l'.
 */
#define add_ms(h,l,val) add_timed_val(h,l,val,1000000)


/* 
 * Macro add_us(h,l,val) adds 'val' number of micro seconds
 * to a time value, stored in 'h' and 'l'.
 */
#define add_us(h,l,val) add_timed_val(h,l,val,1000)


/* 
 * Macro add_ns(h,l,val) adds 'val' number of nano seconds
 * to a time value, stored in 'h' and 'l'.
 */
#define add_ns(h,l,val) add_timed_val(h,l,val,1)


/** 
 * Function delay_until(high,low) waits until the time
 * expressied in parameters 'high' and 'low' is reached.
 */
static inline void delay_until(unsigned int high, unsigned int low)
{
  __asm__ __volatile__("addi  x3,%[h],0;"
                       "addi  x2,%[l],0;"
                       ".word 0x00C4015B;"
                       : 
                       : [h]"r"(high), [l]"r"(low)
                       : "x3", "x2");
}


void (*exception_handler)();
unsigned int exception_ns_h;
unsigned int exception_ns_l;

void exception_proxy()
{
    // Save state. Function should save ra, s0-s11 if used.
  __asm__ __volatile__("mfpcr  tp, cr1;"
                       "addi sp, sp, -68;"
                       "sw tp, 4(sp);"
                       "sw v0, 8(sp);"
                       "sw v1, 12(sp);"
                       "sw a0, 16(sp);"
                       "sw a1, 20(sp);"
                       "sw a2, 24(sp);"
                       "sw a3, 28(sp);"
                       "sw a4, 32(sp);"
                       "sw a5, 36(sp);"
                       "sw a6, 40(sp);"
                       "sw a7, 44(sp);"
                       "sw a8, 48(sp);"
                       "sw a9, 52(sp);"
                       "sw a10, 56(sp);"
                       "sw a11, 60(sp);"
                       "sw a12, 64(sp);"
                       "sw a13, 68(sp);"
                       : 
                       : 
                       : );

    // Call exception handler.
    exception_handler();

    // Restore state.
  __asm__ __volatile__("lw tp, 4(sp);"
                       "lw v0, 8(sp);"
                       "lw v1, 12(sp);"
                       "lw a0, 16(sp);"
                       "lw a1, 20(sp);"
                       "lw a2, 24(sp);"
                       "lw a3, 28(sp);"
                       "lw a4, 32(sp);"
                       "lw a5, 36(sp);"
                       "lw a6, 40(sp);"
                       "lw a7, 44(sp);"
                       "lw a8, 48(sp);"
                       "lw a9, 52(sp);"
                       "lw a10, 56(sp);"
                       "lw a11, 60(sp);"
                       "lw a12, 64(sp);"
                       "lw a13, 68(sp);"
                       "addi sp, sp, 68;" 
                       : 
                       : 
                       : );

  // TODO: x31's state is not restored.
  __asm__ __volatile__(
                       "lw     ra,4(sp);" 
                       "add    sp,sp,8;"
                       "jalr.j x0, tp, 0;"                       
                       : 
                       :
                       : );  
}


/**
 * Function exception_on_expire(high, low, exception_handler) creates an
 * exception handler that is raised at thime 'high' and 'low'.
 */
// TODO: exception_handler argument currently not supported.
static inline void exception_on_expire(unsigned int high, unsigned int low, void* handler)
{
    exception_handler = handler;
    exception_ns_h = high;
    exception_ns_l = low;
  __asm__ __volatile__("mtpcr %[eproxy], cr3;"
                       "addi  x3,%[h],0;"
                       "addi  x2,%[l],0;"
                       ".word 0x00C401DB;"
                       :  
                       : [eproxy]"r"(exception_proxy),
                         [h]"r"(high), [l]"r"(low)
                       : "x3", "x2");
}




/** Function deactivate_exception() deactivates a timing exception
 *  created by exception_on_expire(). 
 */
static inline void deactive_exception()
{
  __asm__ __volatile__(".word 0x0000025B;" : : : );
}

/** Function activate_exception() activates a timing exception
 *  created by the last exception_on_expire(). 
 */
static inline void active_exception()
{
  __asm__ __volatile__("mtpcr %[eproxy], cr3;"
                       "addi  x3,%[h],0;"
                       "addi  x2,%[l],0;"
                       ".word 0x00C401DB;"
                       :  
                       : [eproxy]"r"(exception_proxy),
                         [h]"r"(exception_ns_h), [l]"r"(exception_ns_l)
                       : "x3", "x2");
}


/** Function thread_sleep() puts the current thread into
 *  sleep, such that other hardware threads can utilize
 *  its cycles. 
 */
static inline void thread_sleep()
{
  __asm__ __volatile__(".word 0x000002DB;" : : : );
}


#endif


        
