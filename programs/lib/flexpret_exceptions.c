#include "flexpret_exceptions.h"
#include "flexpret_io.h"
#include "flexpret_csrs.h"
#include "flexpret_assert.h"


typedef void (*isr_t)(void);

static isr_t ext_int_handler;
static isr_t ie_int_handler;
static isr_t ee_int_handler;


static void register_exception_handler(void (*isr)(void)) {
  write_csr(CSR_EVEC, (uint32_t) isr);
}

static void fp_exception_handler(void) {
    int cause = read_csr(CSR_CAUSE);
    // gpo_write_0(0xF);
    gpo_write_0(cause);
    
    if (cause == EXC_CAUSE_EXTERNAL_INT) {  
        if(ext_int_handler) ext_int_handler();
    } else if (cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        if(ie_int_handler) ie_int_handler();
    } else if (cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        if(ee_int_handler) ee_int_handler();
    } else {
        _fp_print(cause);
        ASSERT(false);
    }
}

void setup_exceptions() {
    // Initialize the interrupt handlers to null pointers
    ie_int_handler = (isr_t) 0;
    ee_int_handler = (isr_t) 0;
    ext_int_handler = (isr_t) 0;
    
    // Register the exception handler
    write_csr(CSR_EVEC, (uint32_t) fp_exception_handler);
}

void register_isr(int cause, void (*isr)(void)) {

    if (cause == EXC_CAUSE_EXTERNAL_INT) {
        ext_int_handler = isr;
    } else if (cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        ie_int_handler = isr;
    } else if (cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        ee_int_handler = isr;
    } else {
        ASSERT(false);
    }
}

void exception_on_expire(unsigned timeout_ns) {
  write_csr(CSR_COMPARE, timeout_ns);
  __asm__ volatile(".word 0x705B;");
}

void interrupt_on_expire(unsigned timeout_ns) {
  write_csr(CSR_COMPARE, timeout_ns);
  __asm__ volatile(".word 0x200705B;");
}

void enable_interrupts() 
{
  set_csr(CSR_STATUS,16);
}

void disable_interrupts() 
{
  clear_csr(CSR_STATUS,16);
}
