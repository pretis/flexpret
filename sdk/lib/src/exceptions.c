#include <flexpret/exceptions.h>
#include <flexpret/io.h>
#include <flexpret/csrs.h>
#include <flexpret/assert.h>

#include <flexpret/flexpret.h>
#include <errno.h>
#include <setjmp.h>

typedef void (*isr_t)(void);

static isr_t ext_int_handler[FP_THREADS] = THREAD_ARRAY_INITIALIZER(NULL);
static isr_t ie_int_handler[FP_THREADS] = THREAD_ARRAY_INITIALIZER(NULL);
static isr_t ee_int_handler[FP_THREADS] = THREAD_ARRAY_INITIALIZER(NULL);

struct thread_ctx_t contexts[FP_THREADS];

jmp_buf __ie_jmp_buf[FP_THREADS];
jmp_buf __ee_jmp_buf[FP_THREADS];

bool    __ie_jmp_buf_active[FP_THREADS] = THREAD_ARRAY_INITIALIZER(false);
bool    __ee_jmp_buf_active[FP_THREADS] = THREAD_ARRAY_INITIALIZER(false);

#ifndef NDEBUG
uint32_t __stack_chk_guard = STACK_GUARD_INITVAL;

FP_TEST_OVERRIDE
void __stack_chk_fail(void) {
    register uint32_t linkreg = rdlinkreg();
    register uint32_t stack_ptr = rdstackptr();
    _fp_abort("Stack check failed: link register (%p), stack ptr (%p)\n", linkreg, stack_ptr);
}
#endif // NDEBUG

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
    case EXC_CAUSE_EXTERNAL_INT: return "External interrupt";
    default: return "Unknown exception code";
    }
}

void fp_exception_handler(void) {
    int cause = read_csr(CSR_CAUSE);
    uint32_t hartid = read_hartid();

    if (cause == EXC_CAUSE_EXTERNAL_INT) {  
        if(ext_int_handler[hartid]) ext_int_handler[hartid]();
    } else if (cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        if(ie_int_handler[hartid]) ie_int_handler[hartid]();
    } else if (cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        if(ee_int_handler[hartid]) ee_int_handler[hartid]();
    } else {
        fp_assert(false, "Exception not handled: %i, %s\n", cause, exception_to_str(cause));
    }

    if (__ie_jmp_buf_active[hartid]) {
        longjmp(__ie_jmp_buf[hartid], 1);
    } else if (__ee_jmp_buf_active[hartid]) {
        longjmp(__ee_jmp_buf[hartid], 1);
    } else {
        // Call the function to load the thread's context
        // We mark it with attribute noretun because the function will not return
        // to fp_exception_handler, but instead to where the exception occurred.
        void thread_ctx_switch_load(void) __attribute__((noreturn));    
        // In ctx_switch.S
        thread_ctx_switch_load();
    }
}

void setup_exceptions() {
    // Register the function to call on exceptions; this function stores the
    // thread's context and calls the fp_exception_handler function afterwards
    void thread_ctx_switch_store(void);
    write_csr(CSR_EVEC, (uint32_t) thread_ctx_switch_store);
}

void register_isr(int cause, void (*isr)(void)) {
    uint32_t hartid = read_hartid();
    switch (cause)
    {
    case EXC_CAUSE_EXTERNAL_INT:
        ext_int_handler[hartid] = isr; break;
    case EXC_CAUSE_INTERRUPT_EXPIRE:
        ie_int_handler[hartid]  = isr; break;
    case EXC_CAUSE_EXCEPTION_EXPIRE:
        ee_int_handler[hartid]  = isr; break;
    default: 
        fp_assert(false, "Attempt to register isr for non-supported cause: %i\n", cause);
    }
}