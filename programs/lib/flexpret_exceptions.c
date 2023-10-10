#include "flexpret_exceptions.h"
#include "flexpret_io.h"
#include "flexpret_csrs.h"
#include "flexpret_assert.h"

#include <flexpret.h>

typedef void (*isr_t)(void);

static isr_t ext_int_handler;
static isr_t ie_int_handler;
static isr_t ee_int_handler;


static void register_exception_handler(void (*isr)(void)) {
  write_csr(CSR_EVEC, (uint32_t) isr);
}

static const char *exception_to_str(const uint32_t cause) {
    switch (cause)
    {
    case EXC_CAUSE_MISALIGNED_FETCH: return "Misaligned fetch";
    case EXC_CAUSE_FAULT_FETCH: return "Fetch fault";
    case EXC_CAUSE_ILLEGAL_INSTRUCTION: return "Illegal instruction";
    case EXC_CAUSE_PRIVILEGED_INSTRUCTION: return "Privileged instruction";
    case EXC_CAUSE_FP_DISABLED: return "Floating point unit disabled";
    case EXC_CAUSE_SYSCALL: return "System call";
    case EXC_CAUSE_BREAKPOINT: return "Break point";
    case EXC_CAUSE_MISALIGNED_LOAD: return "Misaligned address on load";
    case EXC_CAUSE_MISALIGNED_STORE: return "Misaligned address on store";
    case EXC_CAUSE_FAULT_LOAD: return "Load fault";
    case EXC_CAUSE_FAULT_STORE: return "Store fault";
    case EXC_CAUSE_ACCELERATOR_DISABLED: return "Accelerator disabled";
    case EXC_CAUSE_EXCEPTION_EXPIRE: return "Exception expire";
    case EXE_CAUSE_EXT_INTERRUPT0: return "External interrupt 0";
    case EXE_CAUSE_EXT_INTERRUPT1: return "External interrupt 1";
    case EXE_CAUSE_EXT_INTERRUPT2: return "External interrupt 2";
    case EXE_CAUSE_EXT_INTERRUPT3: return "External interrupt 3";
    case EXE_CAUSE_EXT_INTERRUPT4: return "External interrupt 4";
    case EXE_CAUSE_EXT_INTERRUPT5: return "External interrupt 5";
    case EXE_CAUSE_EXT_INTERRUPT6: return "External interrupt 6";
    case EXE_CAUSE_TIMER_INTERRUPT: return "Timer interrupt";
    case EXC_CAUSE_INTERRUPT_EXPIRE: return "Interrupt expire";
    case EXC_CAUSE_EXTERNAL_INT: return "External int"; // FIXME: int = interrupt? 
    default: return "Unknown exception code";
    }
}

static void fp_exception_handler(void) {
    int cause = read_csr(CSR_CAUSE);
    
    if (cause == EXC_CAUSE_EXTERNAL_INT) {  
        if(ext_int_handler) ext_int_handler();
    } else if (cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        if(ie_int_handler) ie_int_handler();
    } else if (cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        if(ee_int_handler) ee_int_handler();
    } else {
        printf("Exception occured: %i, %s\n", cause, exception_to_str(cause));
        assert(false, "Exception not handled");
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
    switch (cause)
    {
    case EXC_CAUSE_EXTERNAL_INT:
        ext_int_handler = isr; break;
    case EXC_CAUSE_INTERRUPT_EXPIRE:
        ie_int_handler  = isr; break;
    case EXC_CAUSE_EXCEPTION_EXPIRE:
        ee_int_handler  = isr; break;
    default: 
        assert(false, "Attempt to register isr for non-supported cause");
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
