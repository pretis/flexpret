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

/**
 * These variables are used to implement the `fp_int_on_expire` and 
 * `fp_exc_on_expire` found in `flexpret_exceptions.h`. The buffer is
 * used to be able to jump, and the active variables below are used to
 * determine whether we should jump or not.
 *
 */
jmp_buf __ie_jmp_buf[FP_THREADS];
jmp_buf __ee_jmp_buf[FP_THREADS];

bool    __ie_jmp_buf_active[FP_THREADS] = THREAD_ARRAY_INITIALIZER(false);
bool    __ee_jmp_buf_active[FP_THREADS] = THREAD_ARRAY_INITIALIZER(false);

// We mark it with attribute noretun because the function will not return
// to fp_exception_handler, but instead to where the exception occurred.
void thread_ctx_switch_load(void) __attribute__((noreturn));
void thread_ctx_switch_store(void);

#ifndef NDEBUG
/**
 * `__stack_chk_guard` and `__stack_chk_fail` are part of the `-fstack-protector`
 * compiler flag. The flag enables checking the stack before and after function
 * calls to detect errors.
 * 
 * `__stack_chk_fail` is called if an error is detected. We override the default
 * implementation with a custom one that prints out the link register and
 * stack pointer - which probably are helpful to know in this case.
 *
 * The printing of the registers involves a few function calls in itself, and if
 * the stack is broken this may or may not fail. But it is better to try.
 *
 */
uint32_t __stack_chk_guard = STACK_GUARD_INITVAL;

FP_TEST_OVERRIDE
void __stack_chk_fail(void) {
    register uint32_t *linkreg = rdlinkreg();
    register uint32_t *stack_ptr = rdstackptr();
    _fp_abort("Stack check failed: link register (%p), stack ptr (%p)\n", linkreg, stack_ptr);
}
#endif // NDEBUG

static void register_exception_handler(void (*isr)(void)) {
    write_csr(CSR_EVEC, (uint32_t) isr);
}

#ifndef NDEBUG
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
#endif // NDEBUG

void fp_exception_handler(void) {
    uint32_t cause = read_csr(CSR_CAUSE);
    uint32_t hartid = read_hartid();

    if (cause == EXC_CAUSE_EXTERNAL_INT) {  
        if(ext_int_handler[hartid]) ext_int_handler[hartid]();
    } else if (cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        if(ie_int_handler[hartid]) ie_int_handler[hartid]();
    } else if (cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        if(ee_int_handler[hartid]) ee_int_handler[hartid]();
    } else {
        fp_assert(false, "Exception not handled: %i, %s\n", (int) cause, exception_to_str(cause));
    }

    if (__ie_jmp_buf_active[hartid] && cause == EXC_CAUSE_INTERRUPT_EXPIRE) {
        /**
        * We get here if an interrupt expire occurred between `fp_int_on_expire`
        * and `fp_int_on_expire_cancel`. (I.e., the interrupt did expire.)
        * 
        * In this case we jump back to the initial `setjmp` call in the 
        * `fp_int_on_expire`, which ultimately runs `goto cleanup`.
        *
        */
        longjmp(__ie_jmp_buf[hartid], 1);
    } else if (__ee_jmp_buf_active[hartid] && cause == EXC_CAUSE_EXCEPTION_EXPIRE) {
        // Same as above, but for exceptions
        longjmp(__ee_jmp_buf[hartid], 1);
    } else {
        // Call the function to load the thread's context
        // In ctx_switch.S
        thread_ctx_switch_load();
    }
}

void setup_exceptions() {
    // Register the function to call on exceptions; this function stores the
    // thread's context and calls the fp_exception_handler function afterwards
    register_exception_handler(thread_ctx_switch_store);
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
